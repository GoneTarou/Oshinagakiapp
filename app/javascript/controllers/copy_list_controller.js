import { Controller } from "@hotwired/stimulus"
import { writeListDraft } from "controllers/list_draft_storage"

export default class extends Controller {
  static targets = ["error"]

  static values = {
    eventId: Number,
    items: Array,
    newListUrl: String
  }

  copy() {
    const fields = this.buildFields()

    if (!writeListDraft(fields)) {
      this.showError()
      return
    }

    window.location.assign(this.newListUrlValue)
  }

  buildFields() {
    const fields = [
      {
        name: "list[event_id]",
        type: "select-one",
        value: String(this.eventIdValue),
        checked: null
      }
    ]

    this.itemsValue.forEach((item, index) => {
      const prefix = `list[list_items_attributes][${index}]`

      fields.push(
        this.textField(`${prefix}[space_number]`, item.space_number),
        this.urlField(`${prefix}[source_url]`, item.source_url),
        this.checkboxField(
          `${prefix}[is_featured]`,
          item.is_featured
        ),
        this.checkboxField(
          `${prefix}[is_adult_content]`,
          item.is_adult_content
        )
      )
    })

    return fields
  }

  textField(name, value) {
    return {
      name,
      type: "text",
      value: value || "",
      checked: null
    }
  }

  urlField(name, value) {
    return {
      name,
      type: "url",
      value: value || "",
      checked: null
    }
  }

  checkboxField(name, checked) {
    return {
      name,
      type: "checkbox",
      value: "1",
      checked: Boolean(checked)
    }
  }

  showError() {
    this.errorTarget.hidden = false
  }
}
