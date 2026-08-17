export const LIST_DRAFT_STORAGE_KEY = "oshinagaki:list-draft:v1"

export function writeListDraft(fields) {
  try {
    window.sessionStorage.setItem(
      LIST_DRAFT_STORAGE_KEY,
      JSON.stringify(fields)
    )

    return true
  } catch {
    return false
  }
}

export function readListDraft() {
  try {
    const value = window.sessionStorage.getItem(LIST_DRAFT_STORAGE_KEY)

    if (!value) return null

    const draft = JSON.parse(value)
    return Array.isArray(draft) ? draft : null
  } catch {
    return null
  }
}

export function clearListDraft() {
  try {
    window.sessionStorage.removeItem(LIST_DRAFT_STORAGE_KEY)
  } catch {
    // ストレージを利用できない場合は何もしない
  }
}
