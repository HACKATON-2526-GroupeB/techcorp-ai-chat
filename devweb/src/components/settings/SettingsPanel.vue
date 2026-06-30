<script setup>
import { useSettings } from '../../composables/useSettings'
import { useModels }   from '../../composables/useModels'
import { useChat }     from '../../composables/useChat'

defineProps({ show: Boolean })
defineEmits(['close'])

const { ollamaUrl, temperature, maxTokens, speechLang, autoSave, DEFAULT_URL, SPEECH_LANGS } = useSettings()
const { models } = useModels()
const { activeModel } = useChat()
</script>
<template>
  <Teleport to="body">
    <transition name="fade">
      <div v-if="show" class="fixed inset-0 z-50 flex items-center justify-end">
        <div class="absolute inset-0 bg-black/50" @click="$emit('close')" />
        <div class="relative w-[360px] h-full bg-[#111] border-l border-white/10 flex flex-col shadow-2xl">
          <div class="flex items-center justify-between px-5 py-4 border-b border-white/10">
            <h2 class="text-sm font-semibold text-white">Paramètres</h2>
            <button class="text-white/50 hover:text-white transition" @click="$emit('close')">
              <span class="material-symbols-outlined text-[20px]">close</span>
            </button>
          </div>

          <div class="flex-1 overflow-y-auto px-5 py-4 space-y-5">
            <div>
              <label class="text-xs text-white/50 uppercase tracking-widest">URL Ollama</label>
              <input
                v-model="ollamaUrl"
                type="text"
                class="mt-1 w-full bg-white/5 border border-white/10 rounded-lg px-3 py-2 text-sm text-white outline-none focus:border-white/30"
              />
              <p class="text-[10px] text-white/30 mt-1">Défaut : {{ DEFAULT_URL }}</p>
            </div>

            <div>
              <label class="text-xs text-white/50 uppercase tracking-widest">Modèle</label>
              <select
                v-model="activeModel"
                class="mt-1 w-full bg-white/5 border border-white/10 rounded-lg px-3 py-2 text-sm text-white outline-none"
              >
                <option v-for="m in models" :key="m" :value="m">{{ m }}</option>
              </select>
            </div>

            <div>
              <label class="text-xs text-white/50 uppercase tracking-widest">Température : {{ temperature }}</label>
              <input v-model.number="temperature" type="range" min="0" max="1" step="0.05" class="mt-2 w-full accent-indigo-500" />
            </div>

            <div>
              <label class="text-xs text-white/50 uppercase tracking-widest">Tokens max : {{ maxTokens }}</label>
              <input v-model.number="maxTokens" type="range" min="256" max="4096" step="256" class="mt-2 w-full accent-indigo-500" />
            </div>

            <div>
              <label class="text-xs text-white/50 uppercase tracking-widest">Langue vocale</label>
              <select
                v-model="speechLang"
                class="mt-1 w-full bg-white/5 border border-white/10 rounded-lg px-3 py-2 text-sm text-white outline-none"
              >
                <option v-for="l in SPEECH_LANGS" :key="l.value" :value="l.value">{{ l.label }}</option>
              </select>
            </div>

            <div class="flex items-center justify-between">
              <label class="text-xs text-white/50 uppercase tracking-widest">Sauvegarde auto</label>
              <button
                class="w-10 h-5 rounded-full transition"
                :class="autoSave ? 'bg-indigo-500' : 'bg-white/20'"
                @click="autoSave = !autoSave"
              >
                <span
                  class="block w-4 h-4 bg-white rounded-full shadow transition-transform mx-0.5"
                  :class="autoSave ? 'translate-x-5' : 'translate-x-0'"
                />
              </button>
            </div>
          </div>
        </div>
      </div>
    </transition>
  </Teleport>
</template>
<style scoped>
.fade-enter-active, .fade-leave-active { transition: opacity 0.2s; }
.fade-enter-from, .fade-leave-to { opacity: 0; }
</style>
