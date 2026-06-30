<script setup>
import { computed, ref } from 'vue'
import { marked }        from 'marked'
import { ERROR_TYPES }   from '../../services/errorService'

const props = defineProps({ message: Object, streaming: Boolean })

const copied = ref(false)

const renderedHtml = computed(() => {
  if (!props.message.content) return ''
  return marked.parse(props.message.content, { breaks: true, gfm: true })
})

function fmt(ts) {
  return new Date(ts).toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })
}
function errMeta(type) {
  return ERROR_TYPES[type] ?? ERROR_TYPES.NETWORK
}
async function copy() {
  await navigator.clipboard.writeText(props.message.content)
  copied.value = true
  setTimeout(() => { copied.value = false }, 2000)
}
</script>

<template>
  <div v-if="message.content || message.error" class="flex gap-3 mb-5 px-4 group">
    <div class="w-8 h-8 rounded-xl bg-indigo-600/40 border border-indigo-500/20 flex items-center justify-center flex-shrink-0 mt-1">
      <span class="material-symbols-outlined text-[16px] text-indigo-300">auto_awesome</span>
    </div>
    <div class="max-w-[75%] min-w-0">
      <!-- Error state -->
      <div v-if="message.error" class="bg-red-950/60 border border-red-800/40 rounded-2xl rounded-tl-sm px-4 py-3 text-sm">
        <p class="flex items-center gap-2 text-red-400 font-semibold mb-1">
          <span class="material-symbols-outlined text-[18px]">{{ errMeta(message.errorType).icon }}</span>
          {{ errMeta(message.errorType).label }}
        </p>
        <p class="text-white/60 text-xs">{{ errMeta(message.errorType).detail }}</p>
        <p class="text-white/30 text-[10px] mt-2 uppercase tracking-widest">CODE : {{ message.errorType }}</p>
      </div>

      <!-- Normal message -->
      <div v-else class="relative bg-white/5 border border-white/8 rounded-2xl rounded-tl-sm px-4 py-3 text-sm text-white/90 leading-relaxed">
        <div class="prose prose-invert prose-sm max-w-none" v-html="renderedHtml" />
        <!-- Blinking cursor while streaming -->
        <span v-if="streaming" class="inline-block w-0.5 h-4 bg-white/60 animate-pulse ml-0.5 align-middle" />

        <!-- Copy button -->
        <button
          v-if="!streaming"
          class="absolute top-2 right-2 p-1.5 rounded-lg opacity-0 group-hover:opacity-100 transition hover:bg-white/10 text-white/30 hover:text-white"
          :title="copied ? 'Copié !' : 'Copier'"
          @click="copy"
        >
          <span class="material-symbols-outlined text-[15px]">{{ copied ? 'check' : 'content_copy' }}</span>
        </button>
      </div>

      <!-- Timestamp always visible -->
      <p class="text-[10px] text-white/20 mt-1 pl-1">{{ fmt(message.ts) }}</p>
    </div>
  </div>
</template>
