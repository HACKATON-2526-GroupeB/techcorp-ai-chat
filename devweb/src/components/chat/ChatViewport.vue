<script setup>
import { ref, watch, nextTick, computed } from 'vue'
import MessageUser from './MessageUser.vue'
import MessageAI   from './MessageAI.vue'

const props = defineProps({ messages: Array, loading: Boolean })
const emit  = defineEmits(['suggest'])

const viewport      = ref(null)
const showScrollBtn = ref(false)

const CATEGORIES = [
  { icon: 'bar_chart',      color: '#7C5CFC', label: 'Analyse financière',   desc: 'Posez des questions sur des rapports, ratios et tendances.' },
  { icon: 'trending_up',    color: '#4F8DFF', label: 'Données & marchés',    desc: 'Interrogez les données de marché, actions, indices et plus.' },
  { icon: 'description',    color: '#22C55E', label: 'Résumés rapides',       desc: "Obtenez des résumés clairs d'informations financières." },
  { icon: 'lightbulb',      color: '#F59E0B', label: 'Conseils & explications', desc: 'Comprenez les concepts financiers simplement.' },
]

const SUGGESTIONS = [
  "Qu'est-ce que l'EBITDA ?",
  "Expliquez le ratio CET1 Bâle III",
  "Comment fonctionne MiFID II ?",
  "Quelle est la différence entre actif et passif ?",
]

const streamingMsg = computed(() => {
  if (!props.loading) return null
  const last = props.messages[props.messages.length - 1]
  return last?.role === 'assistant' ? last : null
})

function isStreaming(msg) { return streamingMsg.value === msg }

async function scrollBottom() {
  await nextTick()
  if (viewport.value) viewport.value.scrollTop = viewport.value.scrollHeight
}

function onScroll() {
  if (!viewport.value) return
  const { scrollTop, scrollHeight, clientHeight } = viewport.value
  showScrollBtn.value = scrollHeight - scrollTop - clientHeight > 100
}

watch(() => props.messages, scrollBottom, { deep: true })
</script>

<template>
  <div class="relative flex-1 overflow-hidden">
    <div ref="viewport" class="h-full overflow-y-auto" @scroll="onScroll">

      <!-- Welcome screen -->
      <div v-if="!messages.length" class="flex flex-col items-center justify-center min-h-full py-12 px-8">
        <!-- Hero -->
        <div class="text-center mb-10 animate-float">
          <div class="w-16 h-16 rounded-2xl flex items-center justify-center mx-auto mb-5" style="background:linear-gradient(135deg,#7C5CFC,#5A4FCF);box-shadow:0 8px 32px rgba(124,92,252,0.4)">
            <span class="material-symbols-outlined text-white text-[32px]">auto_awesome</span>
          </div>
          <h1 class="text-4xl font-bold text-white mb-3" style="letter-spacing:-0.02em">Bonjour !</h1>
          <p class="text-white/50 text-base">Je suis votre assistant IA. Posez votre première question financière.</p>
        </div>

        <!-- Category cards -->
        <div class="grid grid-cols-2 gap-3 w-full max-w-2xl mb-8 card-stagger">
          <button
            v-for="c in CATEGORIES"
            :key="c.label"
            class="card text-left p-5 cursor-pointer group"
            @click="emit('suggest', c.label)"
          >
            <div class="w-10 h-10 rounded-xl flex items-center justify-center mb-3 transition group-hover:scale-110" :style="`background:${c.color}22`">
              <span class="material-symbols-outlined text-[20px]" :style="`color:${c.color}`">{{ c.icon }}</span>
            </div>
            <p class="text-sm font-semibold text-white mb-1">{{ c.label }}</p>
            <p class="text-xs text-white/40 leading-relaxed">{{ c.desc }}</p>
            <div class="flex items-center justify-end mt-3">
              <span class="w-6 h-6 rounded-full flex items-center justify-center text-white/30 group-hover:text-white group-hover:bg-white/10 transition" style="border:1px solid rgba(255,255,255,0.1)">
                <span class="material-symbols-outlined text-[13px]">arrow_forward</span>
              </span>
            </div>
          </button>
        </div>

        <!-- Suggested questions -->
        <div class="flex flex-wrap gap-2 justify-center max-w-xl">
          <button
            v-for="s in SUGGESTIONS"
            :key="s"
            class="px-3.5 py-2 rounded-full text-xs text-white/55 hover:text-white transition border border-white/8 hover:border-[#7C5CFC]/40 hover:bg-[#7C5CFC]/10"
            style="background:rgba(255,255,255,0.03)"
            @click="emit('suggest', s)"
          >
            {{ s }}
          </button>
        </div>

        <!-- Security note -->
        <p class="mt-6 text-xs text-white/25 flex items-center gap-1.5">
          <span class="material-symbols-outlined text-[14px]">shield</span>
          Vos données sont sécurisées et confidentielles.
        </p>
      </div>

      <!-- Messages -->
      <div v-else class="py-6 max-w-3xl mx-auto">
        <TransitionGroup name="msg" tag="div">
          <template v-for="msg in messages" :key="msg.ts">
            <MessageUser v-if="msg.role === 'user'" :message="msg" />
            <MessageAI   v-else :message="msg" :streaming="isStreaming(msg)" />
          </template>
        </TransitionGroup>

        <!-- Typing dots -->
        <div v-if="loading && streamingMsg && !streamingMsg.content" class="flex gap-3 px-4 mb-4 items-start">
          <div class="w-8 h-8 rounded-xl flex items-center justify-center flex-shrink-0" style="background:linear-gradient(135deg,#7C5CFC,#5A4FCF)">
            <span class="material-symbols-outlined text-white text-[15px]">auto_awesome</span>
          </div>
          <div class="px-4 py-3 rounded-2xl rounded-tl-sm flex items-center gap-1.5" style="background:#181825;border:1px solid rgba(255,255,255,0.06)">
            <span v-for="i in 3" :key="i" class="w-1.5 h-1.5 rounded-full bg-white/40 animate-dot" :style="`animation-delay:${(i-1)*0.15}s`" />
          </div>
        </div>
      </div>
    </div>

    <!-- Scroll to bottom -->
    <Transition name="fade">
      <button
        v-if="showScrollBtn"
        class="absolute bottom-4 right-4 w-9 h-9 rounded-full flex items-center justify-center text-white/60 hover:text-white transition shadow-lg border border-white/10"
        style="background:#181825"
        @click="scrollBottom"
      >
        <span class="material-symbols-outlined text-[20px]">keyboard_arrow_down</span>
      </button>
    </Transition>
  </div>
</template>
