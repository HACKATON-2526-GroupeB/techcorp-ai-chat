<script setup>
import { useModels } from '../../composables/useModels'
import { useChat }   from '../../composables/useChat'

defineProps({ ollamaOnline: Boolean })
defineEmits(['toggle-settings'])

const { availableModels } = useModels()
const { activeModel }     = useChat()
</script>

<template>
  <header class="flex items-center justify-between px-5 py-3.5 border-b border-white/5 flex-shrink-0" style="background:rgba(9,9,11,0.7);backdrop-filter:blur(20px)">
    <!-- Left: logo + status -->
    <div class="flex items-center gap-2.5">
      <div class="w-7 h-7 rounded-lg flex items-center justify-center" style="background:linear-gradient(135deg,#7C5CFC,#5A4FCF)">
        <span class="material-symbols-outlined text-white text-[15px]">auto_awesome</span>
      </div>
      <span class="text-sm font-semibold text-white">TechCorp AI</span>
      <span
        class="w-2 h-2 rounded-full flex-shrink-0"
        :class="ollamaOnline ? 'bg-[#22C55E]' : 'bg-red-500'"
        :style="ollamaOnline ? 'box-shadow:0 0 6px #22C55E' : ''"
      />
    </div>

    <!-- Center: model selector -->
    <div v-if="availableModels.length" class="flex-1 flex justify-center">
      <div class="relative">
        <select
          v-model="activeModel"
          class="appearance-none pl-3 pr-8 py-1.5 rounded-lg text-xs text-white/80 font-medium outline-none cursor-pointer border border-white/10 transition hover:border-[#7C5CFC]/40"
          style="background:#181825"
        >
          <option v-for="m in availableModels" :key="m" :value="m">{{ m.replace(':latest','') }}</option>
        </select>
        <span class="material-symbols-outlined text-white/40 text-[14px] absolute right-2 top-1/2 -translate-y-1/2 pointer-events-none">expand_more</span>
      </div>
    </div>

    <!-- Right: icons -->
    <div class="flex items-center gap-1">
      <button class="p-2 rounded-lg hover:bg-white/8 text-white/40 hover:text-white transition" title="Thème">
        <span class="material-symbols-outlined text-[18px]">light_mode</span>
      </button>
      <button class="p-2 rounded-lg hover:bg-white/8 text-white/40 hover:text-white transition" title="Paramètres" @click="$emit('toggle-settings')">
        <span class="material-symbols-outlined text-[18px]">settings</span>
      </button>
    </div>
  </header>
</template>
