import { ref, reactive } from 'vue'
import { streamChat, checkOllama } from '../services/ollama'
import { useSettings }             from './useSettings'
import { useHistory }              from './useHistory'
import { useErrors, resolveErrorType, chatErrorMessage } from '../services/errorService'

const { ollamaUrl, temperature, maxTokens } = useSettings()
const { saveSession }                       = useHistory()
const { push }                              = useErrors()

// ─── Singleton module-level ───────────────────────────────────────────────────
const messages         = ref([])
const loading          = ref(false)
const ollamaOnline     = ref(false)
const activeModel      = ref('phi3-financial:latest')
const currentSessionId = ref(null)

export function useChat() {
  async function checkStatus() {
    ollamaOnline.value = await checkOllama(ollamaUrl.value)
  }

  async function send(userInput) {
    if (!userInput.trim() || loading.value) return

    messages.value.push({ role: 'user', content: userInput, ts: new Date() })
    loading.value = true

    const aiMsg = reactive({
      role:      'assistant',
      content:   '',
      ts:        new Date(),
      error:     false,
      errorType: null,
    })
    messages.value.push(aiMsg)

    const history = messages.value
      .slice(0, -1)
      .map(m => ({ role: m.role, content: m.content }))

    try {
      for await (const chunk of streamChat(
        history, activeModel.value, ollamaUrl.value,
        { temperature: temperature.value, maxTokens: maxTokens.value }
      )) {
        aiMsg.content += chunk
      }
    } catch (err) {
      const entry     = push(err)
      const type      = entry.type
      aiMsg.error     = true
      aiMsg.errorType = type
      aiMsg.content   = chatErrorMessage(type, entry.detail)
    }

    loading.value = false

    const { autoSave } = useSettings()
    if (autoSave.value) {
      currentSessionId.value = saveSession(messages.value, currentSessionId.value)
    }
  }

  function clearChat() {
    const { autoSave } = useSettings()
    if (messages.value.length > 0 && autoSave.value) {
      saveSession(messages.value, currentSessionId.value)
    }
    messages.value        = []
    currentSessionId.value = null
  }

  function loadSession(session) {
    const { autoSave } = useSettings()
    if (messages.value.length > 0 && autoSave.value) {
      saveSession(messages.value, currentSessionId.value)
    }
    messages.value         = session.messages.map(m => reactive({ ...m, ts: new Date(m.ts) }))
    currentSessionId.value = session.id
  }

  return {
    messages, loading, ollamaOnline, activeModel, currentSessionId,
    send, clearChat, loadSession, checkStatus,
  }
}
