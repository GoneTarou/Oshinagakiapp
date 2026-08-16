import { Controller } from "@hotwired/stimulus"

let twitterWidgetsPromise

export default class extends Controller {
  static targets = ["input", "preview", "message"]

  connect() {
    this.renderVersion = 0
    this.render()
  }

  disconnect() {
    window.clearTimeout(this.renderTimeout)
    this.renderVersion += 1
  }

  queueRender() {
    window.clearTimeout(this.renderTimeout)

    this.renderTimeout = window.setTimeout(() => {
      this.render()
    }, 400)
  }

  render() {
    const renderVersion = ++this.renderVersion
    const value = this.inputTarget.value.trim()

    this.previewTarget.replaceChildren()
    this.previewTarget.hidden = true
    this.messageTarget.hidden = true

    if (value === "") return

    const url = this.parseUrl(value)

    if (url && this.isPixivUrl(url)) {
      this.showMessage("Pixivのプレビューには未対応です。")
      return
    }

    if (!url || !this.isXPostUrl(url)) {
      this.showMessage("Xの投稿URLを入力してください。", true)
      return
    }

    const blockquote = document.createElement("blockquote")
    blockquote.className = "twitter-tweet"
    blockquote.dataset.width = "550"
    blockquote.dataset.align = "center"

    const link = document.createElement("a")
    link.href = url.href
    link.textContent = url.href

    blockquote.appendChild(link)
    this.previewTarget.appendChild(blockquote)
    this.previewTarget.hidden = false

    void this.loadTwitterWidgets()
      .then(() => {
        if (!this.isCurrentRender(renderVersion)) return

        window.twttr.widgets.load(this.previewTarget)
      })
      .catch(() => {
        if (!this.isCurrentRender(renderVersion)) return

        this.previewTarget.replaceChildren()
        this.previewTarget.hidden = true
        this.showMessage("Xポストのプレビューを表示できませんでした。", true)
      })
  }

  parseUrl(value) {
    try {
      const url = new URL(value)

      if (!["http:", "https:"].includes(url.protocol)) return null

      return url
    } catch {
      return null
    }
  }

  isXPostUrl(url) {
    if (url.hostname !== "x.com") return false

    return /^\/[^/]+\/status\/\d+\/?$/.test(url.pathname)
  }

  isPixivUrl(url) {
    return ["pixiv.net", "www.pixiv.net"].includes(url.hostname)
  }

  isCurrentRender(renderVersion) {
    return this.renderVersion === renderVersion
  }

  showMessage(message, isError = false) {
    this.messageTarget.textContent = message
    this.messageTarget.classList.toggle("text-error", isError)
    this.messageTarget.classList.toggle("text-base-content/70", !isError)
    this.messageTarget.hidden = false
  }

  loadTwitterWidgets() {
    if (window.twttr?.widgets) return Promise.resolve()

    if (twitterWidgetsPromise) return twitterWidgetsPromise

    twitterWidgetsPromise = new Promise((resolve, reject) => {
      const existingScript = document.querySelector(
        'script[src="https://platform.twitter.com/widgets.js"]'
      )

      const script = existingScript || document.createElement("script")
      let settled = false
      let timeoutId

      const resolveOnce = () => {
        if (settled) return

        settled = true
        window.clearTimeout(timeoutId)

        if (window.twttr?.widgets) {
          resolve()
        } else {
          reject(new Error("Xウィジェットを利用できません"))
        }
      }

      const rejectOnce = () => {
        if (settled) return

        settled = true
        window.clearTimeout(timeoutId)
        reject(new Error("Xウィジェットの読み込みに失敗しました"))
      }

      script.addEventListener("load", resolveOnce, { once: true })
      script.addEventListener("error", rejectOnce, { once: true })

      timeoutId = window.setTimeout(rejectOnce, 10000)

      if (!existingScript) {
        script.src = "https://platform.twitter.com/widgets.js"
        script.async = true
        document.head.appendChild(script)
      }
    }).catch((error) => {
      twitterWidgetsPromise = null
      throw error
    })

    return twitterWidgetsPromise
  }
}
