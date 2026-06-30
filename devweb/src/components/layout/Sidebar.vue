<script setup>
import { ref, computed } from 'vue'
import { useHistory } from '../../composables/useHistory'
import { useChat }    from '../../composables/useChat'
import SidebarSection from './SidebarSection.vue'

const emit = defineEmits(['clear-chat', 'toggle-settings'])
const { recentSessions, archivedSessions, deleteSession, relativeTime } = useHistory()
const { loadSession, currentSessionId } = useChat()

const search = ref('')

const filteredRecent = computed(() =>
  search.value
    ? recentSessions.value.filter(s => s.title.toLowerCase().includes(search.value.toLowerCase()))
    : recentSessions.value
)
</script>

<template>
  <aside class="fixed left-0 top-0 h-full w-[280px] bg-[#0a0a0f]/95 backdrop-blur-md border-r border-white/8 flex flex-col z-20">
    <!-- Header -->
    <div class="px-4 py-4 border-b border-white/8 flex-shrink-0">
      <div class="flex items-center justify-between mb-3">
        <span class="font-bold text-white text-base tracking-tight">TechCorp</span>
        <button
          class="flex items-center gap-1 text-xs text-white/50 hover:text-white transition px-2 py-1 rounded-lg hover:bg-white/10"
          @click="emit('clear-chat')"
        >
          <span class="material-symbols-outlined text-[15px]">add</span>
          Nouveau
        </button>
      </div>
      <!-- Search -->
      <div class="relative">
        <span class="material-symbols-outlined text-[15px] text-white/30 absolute left-2.5 top-1/2 -translate-y-1/2">search</span>
        <input
          v-model="search"
          type="text"
          placeholder="Rechercher…"
          class="w-full bg-white/5 border border-white/10 rounded-lg pl-8 pr-3 py-1.5 text-xs text-white placeholder-white/30 outline-none focus:border-white/25 transition"
        />
      </div>
    </div>

    <!-- Session list -->
    <div class="flex-1 overflow-y-auto px-2 py-3">
      <SidebarSection v-if="filteredRecent.length" title="Récent">
        <div
          v-for="s in filteredRecent"
          :key="s.id"
          class="flex items-center group rounded-xl hover:bg-white/8 transition mb-0.5"
          :class="s.id === currentSessionId ? 'bg-white/8' : ''"
        >
          <button
            class="flex-1 text-left px-3 py-2 min-w-0"
            :class="s.id === currentSessionId ? 'text-white' : 'text-white/55'"
            @click="loadSession(s)"
          >
            <span class="truncate block text-sm">{{ s.title }}</span>
            <span class="text-[10px] text-white/25">{{ relativeTime(s.ts) }}</span>
          </button>
          <button
            class="p-1.5 mr-1 rounded-lg opacity-0 group-hover:opacity-100 text-white/30 hover:text-red-400 hover:bg-red-900/30 transition flex-shrink-0"
            title="Supprimer"
            @click.stop="deleteSession(s.id)"
          >
            <span class="material-symbols-outlined text-[14px]">delete</span>
          </button>
        </div>
        <p v-if="search && !filteredRecent.length" class="text-xs text-white/25 px-3 py-2">Aucun résultat</p>
      </SidebarSection>

      <SidebarSection v-if="archivedSessions.length && !search" title="Archivé">
        <div
          v-for="s in archivedSessions"
          :key="s.id"
          class="flex items-center group rounded-xl hover:bg-white/8 transition mb-0.5"
        >
          <button class="flex-1 text-left px-3 py-2 text-sm text-white/35 truncate" @click="loadSession(s)">
            {{ s.title }}
          </button>
          <button
            class="p-1.5 mr-1 rounded-lg opacity-0 group-hover:opacity-100 text-white/30 hover:text-red-400 hover:bg-red-900/30 transition flex-shrink-0"
            title="Supprimer"
            @click.stop="deleteSession(s.id)"
          >
            <span class="material-symbols-outlined text-[14px]">delete</span>
          </button>
        </div>
      </SidebarSection>

      <div v-if="!recentSessions.length && !search" class="flex flex-col items-center justify-center h-32 text-white/20 gap-2">
        <span class="material-symbols-outlined text-[28px]">chat_bubble_outline</span>
        <p class="text-xs">Aucune conversation</p>
      </div>
    </div>

    <!-- Footer -->
    <div class="border-t border-white/8 px-4 py-3 flex-shrink-0">
      <p class="text-[10px] text-white/20 text-center">phi3-financial · TechCorp AI</p>
    </div>
  </aside>
</template>
