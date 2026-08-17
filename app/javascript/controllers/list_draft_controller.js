import { Controller } from "@hotwired/stimulus"
import {
  clearListDraft,
  readListDraft,
  writeListDraft
} from "controllers/list_draft_storage"

export default class extends Controller {
  static values = { reset: Boolean }

  connect() {
    if (this.resetValue) {
      this.clear()
      this.resetValue = false
      this.removeResetParameter()
    }

    this.restore()
  }

  save() {
    const fields = this.formFields().map((field) => ({
      name: field.name,
      type: field.type,
      value: field.value,
      checked: field.type === "checkbox" ? field.checked : null
    }))

    writeListDraft(fields)
  }

  restore() {
    const draft = this.readDraft()

    if (!draft) return

    const fieldsByName = new Map(draft.map((field) => [field.name, field]))
    const restoredFields = []

    this.formFields().forEach((field) => {
      const savedField = fieldsByName.get(field.name)

      if (!savedField) return

      if (field.type === "checkbox") {
        field.checked = savedField.checked
      } else {
        field.value = savedField.value
      }

      restoredFields.push(field)
    })

    requestAnimationFrame(() => {
      restoredFields.forEach((field) => {
        if (field.type === "url") {
          field.dispatchEvent(new Event("input", { bubbles: true }))
        }

        if (field.type === "checkbox") {
          field.dispatchEvent(new Event("change", { bubbles: true }))
        }
      })

      window.dispatchEvent(new CustomEvent("list-draft:restored"))
    })
  }

  formFields() {
    return Array.from(
      this.element.querySelectorAll(
        'select[name^="list["], input[type="text"][name^="list["], input[type="url"][name^="list["], input[type="checkbox"][name^="list["]'
      )
    )
  }

  readDraft() {
    return readListDraft()
  }

  clear() {
    clearListDraft()
  }

  removeResetParameter() {
    const url = new URL(window.location.href)
    url.searchParams.delete("reset_draft")

    window.history.replaceState(window.history.state, "", url.toString())
  }
}
