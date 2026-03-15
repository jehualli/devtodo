const KeyboardShortcuts = {
  mounted() {
    this.handleKeydown = (e) => {
      // Ignore if typing in an input/textarea
      const tag = document.activeElement.tagName.toLowerCase()
      const isEditing = tag === 'input' || tag === 'textarea' || tag === 'select'

      // '/' to focus search (allow from anywhere)
      if (e.key === '/' && !isEditing) {
        e.preventDefault()
        const search = document.getElementById('search-input')
        if (search) {
          search.focus()
          search.select()
        }
        return
      }

      // Escape to clear filters / blur search
      if (e.key === 'Escape') {
        if (isEditing) {
          document.activeElement.blur()
          return
        }
        this.pushEvent('clear_filters', {})
        return
      }

      if (isEditing) return

      // 'n' to new task
      if (e.key === 'n' || e.key === 'N') {
        e.preventDefault()
        window.location.href = '/tasks/new'
        return
      }
    }

    window.addEventListener('keydown', this.handleKeydown)
  },

  destroyed() {
    window.removeEventListener('keydown', this.handleKeydown)
  }
}

export default KeyboardShortcuts
