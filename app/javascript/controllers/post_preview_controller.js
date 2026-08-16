import { Controller } from "@hotwired/stimulus"

let twitterWidgetsPromise

export default class extends Controller {
  static targets = ["input", "preview", "message"]

  connect() {
    this.render()
  }

  disconnect() {
    window.clearTimeout(this.renderTimeout)
  }

  queueRender() {
    window.clearTimeout(this.renderTimeout)

    this.renderTimeout = window.setTimeout(() => {
      this.render()
    }, 400)
  }

  render() {
    const value = this.inputTarget.value.trim()

    this.previewTarget.replaceChildren()
    this.previewTarget.hidden = true
    this.messageTarget.hidden = true

    if (value === "") return

    const url = this.parseUrl(value)

    if (!url || !this.isXPostUrl(url)) {
      this.showMessage("Xの投稿URLを入力するとプレビューが表示されます。")
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
        window.twttr.widgets.load(this.previewTarget)
      })
      .catch(() => {
        this.previewTarget.replaceChildren()
        this.previewTarget.hidden = true
        this.showMessage("Xポストのプレビューを表示できませんでした。")
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

  showMessage(message) {
    this.messageTarget.textContent = message
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
