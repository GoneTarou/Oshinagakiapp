import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sourceUrl"]

  scrollToSourceUrl(event) {
    if (event.currentTarget.value === "") return
    if (!this.hasSourceUrlTarget) return

    const prefersReducedMotion = window.matchMedia(
      "(prefers-reduced-motion: reduce)"
    ).matches

    this.sourceUrlTarget.scrollIntoView({
      behavior: prefersReducedMotion ? "auto" : "smooth",
      block: "center"
    })
  }
}
