import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item", "addButton"]

  connect() {
    this.revealFilledItems()
    this.updateAddButton()
  }

  add() {
    const nextItem = this.itemTargets.find((item) => item.hidden)

    if (!nextItem) {
      return
    }

    nextItem.hidden = false
    nextItem.scrollIntoView({
      behavior: "smooth",
      block: "center"
    })

    this.updateAddButton()
  }

  revealFilledItems() {
    this.itemTargets.forEach((item, index) => {
      const hasValue = [
        ...item.querySelectorAll("input[type='text'], input[type='url']")
      ].some(
        (input) => input.value.trim() !== ""
      )

      const hasError = item.querySelector(
        ".input-error, [aria-invalid='true'], [role='alert']"
      )

      if (hasValue || hasError) {
        this.itemTargets
          .slice(0, index + 1)
          .forEach((target) => {
            target.hidden = false
          })
      }
    })
  }

  updateAddButton() {
    const hasHiddenItem = this.itemTargets.some((item) => item.hidden)

    this.addButtonTarget.hidden = !hasHiddenItem
  }
}
