<script setup>
import { ref, watch, nextTick, computed } from 'vue'
import MessageUser from './MessageUser.vue'
import MessageAI   from './MessageAI.vue'

const props = defineProps({ messages: Array, loading: Boolean })
const viewport     = ref(null)
const showScrollBtn = ref(false)

const lastMsg = computed(() => props.messages[props.messages.length - 1])
const streamingMsg = computed(() =>
  props.loading && lastMsg.value?.role === 'assistant' ? lastMsg.value : null
)

function isStreaming(msg) {
  return streamingMsg.value === msg
}

async function scrollBottom() {
  await nextTick()
  if (viewport.value) viewport.value.scrollTop = viewport.value.scrollHeight
}

function onScroll() {
  if (!viewport.value) return
  const { scrollTop, scrollHeight, clientHeight } = viewport.value
  showScrollBtn.value = scrollHeight - scrollTop - clientHeight > 120
}

watch(() => props.messages, scrollBottom, { deep: true })
</script>

<template>
  <div class="relative flex-1 overflow-hidden">
    <div
      ref="viewport"
      class="h-full overflow-y-auto py-6 scroll-smooth"
      @scroll="onScroll"
    >
      <div v-if="!messages.length" class="flex flex-col items-center justify-center h-full text-white/20 gap-3 select-none">
        <span class="material-symbols-outlined text-[48px]">auto_awesome</span>
        <p class="text-sm">Posez votre première question financière</p>
      </div>
      <template v-for="msg in messages" :key="msg.ts">
        <MessageUser v-if="msg.role === 'user'" :message="msg" />
        <MessageAI   v-else :message="msg" :streaming="isStreaming(msg)" />
      </template>
    </div>

    <!-- Scroll to bottom button -->
    <Transition name="fade">
      <button
        v-if="showScrollBtn"
        class="absolute bottom-4 right-4 p-2 rounded-full bg-white/10 hover:bg-white/20 text-white/60 hover:text-white backdrop-blur-sm border border-white/10 transition shadow-lg"
        title="Défiler en bas"
        @click="scrollBottom"
      >
        <span class="material-symbols-outlined text-[20px]">keyboard_arrow_down</span>
      </button>
    </Transition>
  </div>
</template>

<style scoped>
.fade-enter-active, .fade-leave-active { transition: opacity 0.2s; }
.fade-enter-from, .fade-leave-to { opacity: 0; }
</style>
