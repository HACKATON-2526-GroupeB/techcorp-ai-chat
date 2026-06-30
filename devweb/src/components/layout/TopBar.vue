<script setup>
import { useModels } from '../../composables/useModels'
import { useChat }   from '../../composables/useChat'

defineProps({ ollamaOnline: Boolean })
defineEmits(['toggle-settings'])

const { availableModels } = useModels()
const { activeModel }     = useChat()
</script>

<template>
  <header class="flex items-center justify-between px-5 py-3 border-b border-white/10 bg-[#0a0a0a]/80 backdrop-blur-sm flex-shrink-0 gap-4">
    <div class="flex items-center gap-2 flex-shrink-0">
      <span class="text-base font-semibold text-white tracking-tight">TechCorp</span>
      <span
        class="w-2 h-2 rounded-full flex-shrink-0"
        :class="ollamaOnline ? 'bg-green-400' : 'bg-red-500'"
        :title="ollamaOnline ? 'Ollama connecté' : 'Ollama hors ligne'"
      />
    </div>

    <!-- Model selector -->
    <select
      v-if="availableModels.length"
      v-model="activeModel"
      class="flex-1 max-w-[220px] bg-white/5 border border-white/10 rounded-lg px-3 py-1.5 text-xs text-white/80 outline-none hover:border-white/20 transition cursor-pointer"
      title="Changer de modèle"
    >
      <option v-for="m in availableModels" :key="m" :value="m">{{ m }}</option>
    </select>

    <button
      class="p-2 rounded-lg hover:bg-white/10 text-white/50 hover:text-white transition flex-shrink-0"
      title="Paramètres"
      @click="$emit('toggle-settings')"
    >
      <span class="material-symbols-outlined text-[22px]">settings</span>
    </button>
  </header>
</template>
