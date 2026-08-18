import { Controller } from "@hotwired/stimulus"

let twitterWidgetsPromise

const xPostQueue = []
let xPostQueueRunning = false

function enqueueXPost(task) {
  xPostQueue.push(task)
  void processXPostQueue()
}

async function processXPostQueue() {
  if (xPostQueueRunning) return

  xPostQueueRunning = true

  try {
    while (xPostQueue.length > 0) {
      const task = xPostQueue.shift()

      try {
        await task()
      } catch {
        // 個別の投稿失敗では、後続の投稿を止めない
      }
    }
  } finally {
    xPostQueueRunning = false
  }
}

export default class extends Controller {
  static values = {
    url: String,
    pixivTitleUrl: String,
    adult: Boolean
  }

  static targets = ["content", "fallback", "error", "notice", "title"]

  connect() {
    const url = this.parseUrl()

    if (!url) {
      this.showError("正しいURLを入力してください。")
      return
    }

    if (!this.isAllowedUrl(url)) {
      this.showError("許可されていない外部ポストURLです。")
      return
    }

    if (this.isXUrl(url)) {
      this.setupXWidgetLoading(url)
      return
    }

    if (this.isPixivUrl(url)) {
      this.setupPixivTitleLoading()
      return
    }

    this.showFallback()
  }

  disconnect() {
    this.detailsElement?.removeEventListener("toggle", this.detailsToggleHandler)
    this.xPostObserver?.disconnect()
  }

  parseUrl() {
    try {
      const url = new URL(this.urlValue)

      if (!["http:", "https:"].includes(url.protocol)) {
        return null
      }

      return url
    } catch {
      return null
    }
  }

  isAllowedUrl(url) {
    return ["x.com", "pixiv.net", "www.pixiv.net"].includes(url.hostname)
  }

  isXUrl(url) {
    return url.hostname === "x.com"
  }

  isPixivUrl(url) {
    return ["pixiv.net", "www.pixiv.net"].includes(url.hostname)
  }

  setupPixivTitleLoading() {
    if (!this.adultValue) {
      void this.loadPixivTitle()
      return
    }

    this.detailsElement = this.element.closest("details")

    if (!this.detailsElement) return

    this.detailsToggleHandler = () => {
      if (this.detailsElement.open) {
        void this.loadPixivTitle()
      }
    }

    this.detailsElement.addEventListener("toggle", this.detailsToggleHandler)

    if (this.detailsElement.open) {
      void this.loadPixivTitle()
    }
  }

  async loadPixivTitle() {
    if (this.pixivTitleLoading || this.pixivTitleLoaded) return

    this.pixivTitleLoading = true

    try {
      const response = await fetch(this.pixivTitleUrlValue, {
        headers: {
          Accept: "application/json"
        }
      })

      if (!response.ok) {
        throw new Error("Pixivタイトルの取得に失敗しました")
      }

      const data = await response.json()

      this.titleTarget.textContent = data.title
      this.titleTarget.hidden = false
      this.pixivTitleLoaded = true
    } catch {
      this.showPixivTitleError()
    } finally {
      this.pixivTitleLoading = false
    }
  }

  showPixivTitleError() {
    this.errorTarget.textContent = "Pixivタイトルを取得できませんでした。"
    this.errorTarget.hidden = false
    this.fallbackTarget.hidden = false
  }

  setupXWidgetLoading(url) {
    if (!("IntersectionObserver" in window)) {
      this.enqueueXWidget(url)
      return
    }

    this.xPostObserver = new IntersectionObserver(
      (entries) => {
        if (!entries.some((entry) => entry.isIntersecting)) return

        this.xPostObserver.disconnect()
        this.enqueueXWidget(url)
      },
      { rootMargin: "600px 0px" }
    )

    this.xPostObserver.observe(this.element)
  }

  enqueueXWidget(url) {
    if (this.xPostQueued || this.xPostStarted) return

    this.xPostQueued = true
    enqueueXPost(() => this.loadXWidget(url))
  }

  async loadXWidget(url) {
    if (!this.element.isConnected || this.xPostStarted) return

    const tweetId = this.extractTweetId(url)

    if (!tweetId) {
      this.showError("Xの投稿URLを指定してください。")
      return
    }

    this.xPostStarted = true

    try {
      await this.loadTwitterWidgets()

      if (!this.element.isConnected) return

      this.renderXPost(url)
      window.twttr.widgets.load(this.contentTarget)
      this.xPostLoaded = true
    } catch {
      if (this.element.isConnected) {
        this.showXPreviewUnavailable()
      }
    }
  }

  extractTweetId(url) {
    const match = url.pathname.match(/^\/[^/]+\/status\/(\d+)/)

    return match ? match[1] : null
  }

  renderXPost(url) {
    const blockquote = document.createElement("blockquote")
    blockquote.className = "twitter-tweet"
    blockquote.dataset.width = "550"
    blockquote.dataset.align = "center"

    const link = document.createElement("a")
    link.href = url.href
    link.textContent = url.href

    blockquote.appendChild(link)
    this.contentTarget.replaceChildren(blockquote)
    this.contentTarget.hidden = false
    this.noticeTarget.hidden = false
    this.fallbackTarget.hidden = false
    this.errorTarget.hidden = true
  }

  loadTwitterWidgets() {
    if (window.twttr?.widgets) {
      return Promise.resolve()
    }

    if (twitterWidgetsPromise) {
      return twitterWidgetsPromise
    }

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

  showFallback() {
    this.contentTarget.hidden = true
    this.fallbackTarget.hidden = false
    this.errorTarget.hidden = true
    this.noticeTarget.hidden = true
  }

  showError(message) {
    this.contentTarget.hidden = true
    this.fallbackTarget.hidden = true
    this.noticeTarget.hidden = true
    this.errorTarget.textContent = message
    this.errorTarget.hidden = false
  }

  showXPreviewUnavailable() {
    this.contentTarget.hidden = true
    this.fallbackTarget.hidden = false
    this.noticeTarget.hidden = false
    this.errorTarget.textContent =
      "センシティブ設定またはX側の制限によりプレビューできません。"
    this.errorTarget.hidden = false
  }
}
