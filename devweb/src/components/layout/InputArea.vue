<script setup>
import { ref, watch } from 'vue'
import { useSpeech } from '../../composables/useSpeech'

const props = defineProps({ loading: Boolean })
const emit  = defineEmits(['send', 'stop'])

const input = ref('')

const { listening, toggle: toggleSpeech, supported: speechSupported } = useSpeech({
  onResult: (text) => { input.value = text }
})

function handleSend() {
  if (!input.value.trim() || props.loading) return
  emit('send', input.value.trim())
  input.value = ''
}

function handleKeydown(e) {
  if (e.key === 'Enter' && !e.shiftKey) {
    e.preventDefault()
    handleSend()
  }
}
</script>

<template>
  <div class="px-4 py-3 border-t border-white/10 bg-[#0a0a0a] flex gap-2 items-end flex-shrink-0">
    <!-- Voice input -->
    <button
      v-if="speechSupported"
      class="p-3 rounded-xl transition flex-shrink-0"
      :class="listening ? 'bg-red-500/80 text-white animate-pulse' : 'bg-white/5 hover:bg-white/10 text-white/50 hover:text-white'"
      :title="listening ? 'Arrêter la dictée' : 'Dicter'"
      :disabled="loading"
      @click="toggleSpeech"
    >
      <span class="material-symbols-outlined text-[20px]">{{ listening ? 'mic' : 'mic_none' }}</span>
    </button>

    <textarea
      v-model="input"
      rows="1"
      placeholder="Posez votre question financière…"
      class="flex-1 resize-none bg-white/5 rounded-xl px-4 py-3 text-sm text-white placeholder-white/30 outline-none focus:ring-1 focus:ring-white/20 max-h-40 overflow-auto"
      :disabled="loading"
      @keydown="handleKeydown"
    />

    <!-- Stop button while generating -->
    <button
      v-if="loading"
      class="p-3 rounded-xl bg-red-600/80 hover:bg-red-500 text-white transition flex-shrink-0"
      title="Arrêter la génération"
      @click="emit('stop')"
    >
      <span class="material-symbols-outlined text-[20px]">stop</span>
    </button>

    <!-- Send button -->
    <button
      v-else
      class="p-3 rounded-xl bg-white/10 hover:bg-white/20 text-white transition disabled:opacity-30 flex-shrink-0"
      :disabled="!input.trim()"
      title="Envoyer (Entrée)"
      @click="handleSend"
    >
      <span class="material-symbols-outlined text-[20px]">send</span>
    </button>
  </div>
</template>
