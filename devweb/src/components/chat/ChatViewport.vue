<script setup>
import { ref, watch, nextTick, computed } from 'vue'
import MessageUser from './MessageUser.vue'
import MessageAI   from './MessageAI.vue'

const props = defineProps({ messages: Array, loading: Boolean })
const emit  = defineEmits(['suggest'])

const viewport      = ref(null)
const showScrollBtn = ref(false)

const SUGGESTIONS = [
  "Qu'est-ce que l'EBITDA ?",
  "Différence entre actif et passif ?",
  "Comment fonctionne MiFID II ?",
  "Qu'est-ce que le ratio CET1 Bâle III ?",
  "Expliquez le free cash flow",
  "Comment calculer le BFR ?",
]

const streamingMsg = computed(() => {
  if (!props.loading) return null
  const last = props.messages[props.messages.length - 1]
  return last?.role === 'assistant' ? last : null
})

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
    <div ref="viewport" class="h-full overflow-y-auto py-6 scroll-smooth" @scroll="onScroll">

      <!-- Welcome / empty state -->
      <div v-if="!messages.length" class="flex flex-col items-center justify-center h-full gap-8 px-6 select-none">
        <div class="text-center">
          <div class="w-16 h-16 rounded-2xl bg-indigo-600/20 border border-indigo-500/20 flex items-center justify-center mx-auto mb-4">
            <span class="material-symbols-outlined text-[32px] text-indigo-400">auto_awesome</span>
          </div>
          <h2 class="text-white text-xl font-semibold mb-1">TechCorp AI Financial</h2>
          <p class="text-white/40 text-sm">Assistant spécialisé IFRS · GAAP · MiFID II · Bâle III</p>
        </div>

        <!-- Suggested prompts -->
        <div class="flex flex-wrap gap-2 justify-center max-w-lg">
          <button
            v-for="s in SUGGESTIONS"
            :key="s"
            class="px-3 py-2 rounded-xl bg-white/5 border border-white/10 text-xs text-white/60 hover:bg-white/10 hover:text-white hover:border-white/20 transition text-left"
            @click="emit('suggest', s)"
          >
            {{ s }}
          </button>
        </div>
      </div>

      <!-- Messages -->
      <TransitionGroup name="msg" tag="div" v-else>
        <template v-for="msg in messages" :key="msg.ts">
          <MessageUser v-if="msg.role === 'user'" :message="msg" />
          <MessageAI   v-else :message="msg" :streaming="isStreaming(msg)" />
        </template>
      </TransitionGroup>

      <!-- Typing dots (standalone, when AI message is empty) -->
      <div v-if="loading && streamingMsg && !streamingMsg.content" class="flex gap-3 px-4 mb-4">
        <div class="w-8 h-8 rounded-xl bg-indigo-600/50 flex items-center justify-center flex-shrink-0">
          <span class="material-symbols-outlined text-[16px] text-white">auto_awesome</span>
        </div>
        <div class="bg-white/5 rounded-2xl rounded-tl-sm px-4 py-3 flex items-center gap-1">
          <span class="dot" /><span class="dot" style="animation-delay:.15s" /><span class="dot" style="animation-delay:.3s" />
        </div>
      </div>
    </div>

    <!-- Scroll to bottom -->
    <Transition name="fade">
      <button
        v-if="showScrollBtn"
        class="absolute bottom-4 right-4 p-2 rounded-full bg-white/10 hover:bg-white/20 text-white/60 hover:text-white backdrop-blur-sm border border-white/10 transition shadow-lg"
        @click="scrollBottom"
      >
        <span class="material-symbols-outlined text-[20px]">keyboard_arrow_down</span>
      </button>
    </Transition>
  </div>
</template>

<style scoped>
.msg-enter-active { transition: all 0.25s cubic-bezier(0.34, 1.56, 0.64, 1); }
.msg-enter-from   { opacity: 0; transform: translateY(12px); }

.fade-enter-active, .fade-leave-active { transition: opacity 0.2s; }
.fade-enter-from, .fade-leave-to { opacity: 0; }

.dot {
  display: inline-block;
  width: 6px; height: 6px;
  border-radius: 50%;
  background: rgba(255,255,255,0.5);
  animation: bounce 0.8s ease-in-out infinite;
}
@keyframes bounce {
  0%, 100% { transform: translateY(0); opacity: 0.4; }
  50%       { transform: translateY(-5px); opacity: 1; }
}
</style>
