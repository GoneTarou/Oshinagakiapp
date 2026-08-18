import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "dialog",
    "step",
    "progress",
    "previousButton",
    "nextButton",
    "finishButton"
  ]

  static values = {
    storageKey: String
  }

  connect() {
    this.currentStep = 0

    if (this.completed()) return

    this.showStep(this.currentStep)

    this.openFrameId = requestAnimationFrame(() => {
      this.dialogTarget.showModal()
    })
  }

  disconnect() {
    cancelAnimationFrame(this.openFrameId)
  }

  next() {
    this.currentStep += 1
    this.showStep(this.currentStep)
  }

  previous() {
    this.currentStep -= 1
    this.showStep(this.currentStep)
  }

  open() {
    this.currentStep = 0
    this.showStep(this.currentStep)
    this.dialogTarget.showModal()
  }

  finish() {
    this.complete()
  }

  skip(event) {
    event?.preventDefault()
    this.complete()
  }

  showStep(index) {
    this.stepTargets.forEach((step, stepIndex) => {
      step.hidden = stepIndex !== index
    })

    const isLastStep = index === this.stepTargets.length - 1

    this.progressTarget.textContent = `${index + 1} / ${this.stepTargets.length}`
    this.previousButtonTarget.hidden = index === 0
    this.nextButtonTarget.hidden = isLastStep
    this.finishButtonTarget.hidden = !isLastStep
  }

  complete() {
    try {
      localStorage.setItem(this.storageKeyValue, "true")
    } catch {
      // 保存できないブラウザでは、次回もチュートリアルを表示する
    }

    if (this.dialogTarget.open) {
      this.dialogTarget.close()
    }
  }

  completed() {
    try {
      return localStorage.getItem(this.storageKeyValue) === "true"
    } catch {
      return false
    }
  }
}
