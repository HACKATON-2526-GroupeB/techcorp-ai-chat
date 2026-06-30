<script setup>
import { useModels } from '../../composables/useModels'
import { useChat }   from '../../composables/useChat'

defineProps({ ollamaOnline: Boolean })
defineEmits(['toggle-settings'])

const { availableModels } = useModels()
const { activeModel }     = useChat()
</script>

<template>
  <header class="flex items-center justify-between px-5 py-3 border-b border-white/8 bg-black/20 backdrop-blur-md flex-shrink-0 gap-4">
    <!-- Connection status only (no redundant TechCorp text) -->
    <div class="flex items-center gap-2">
      <span
        class="w-2 h-2 rounded-full flex-shrink-0 transition-colors duration-500"
        :class="ollamaOnline ? 'bg-green-400 shadow-[0_0_6px_#4ade80]' : 'bg-red-500'"
      />
      <span class="text-xs text-white/40">{{ ollamaOnline ? 'Connecté' : 'Hors ligne' }}</span>
    </div>

    <!-- Model selector -->
    <select
      v-if="availableModels.length"
      v-model="activeModel"
      class="flex-1 max-w-[240px] bg-white/5 border border-white/10 rounded-lg px-3 py-1.5 text-xs text-white/70 outline-none hover:border-white/25 hover:text-white transition cursor-pointer"
    >
      <option v-for="m in availableModels" :key="m" :value="m">{{ m }}</option>
    </select>

    <button
      class="p-2 rounded-lg hover:bg-white/10 text-white/40 hover:text-white transition flex-shrink-0"
      title="Paramètres"
      @click="$emit('toggle-settings')"
    >
      <span class="material-symbols-outlined text-[20px]">settings</span>
    </button>
  </header>
</template>
