<script setup>
import { useHistory } from '../../composables/useHistory'
import { useChat }    from '../../composables/useChat'
import SidebarSection from './SidebarSection.vue'

const emit = defineEmits(['clear-chat', 'toggle-settings'])
const { recentSessions, archivedSessions, deleteSession, relativeTime } = useHistory()
const { loadSession, currentSessionId } = useChat()
</script>

<template>
  <aside class="fixed left-0 top-0 h-full w-[280px] bg-[#0d0d0d] border-r border-white/10 flex flex-col z-20">
    <div class="px-4 py-4 flex items-center justify-between border-b border-white/10 flex-shrink-0">
      <span class="font-bold text-white text-base tracking-tight">TechCorp</span>
      <button
        class="flex items-center gap-1 text-xs text-white/50 hover:text-white transition px-2 py-1 rounded-lg hover:bg-white/10"
        @click="emit('clear-chat')"
      >
        <span class="material-symbols-outlined text-[16px]">add</span>
        Nouveau
      </button>
    </div>

    <div class="flex-1 overflow-y-auto px-2 py-3">
      <SidebarSection v-if="recentSessions.length" title="Récent">
        <div
          v-for="s in recentSessions"
          :key="s.id"
          class="flex items-center group rounded-lg hover:bg-white/10 transition"
          :class="s.id === currentSessionId ? 'bg-white/10' : ''"
        >
          <button
            class="flex-1 text-left px-3 py-2 text-sm truncate"
            :class="s.id === currentSessionId ? 'text-white' : 'text-white/60'"
            @click="loadSession(s)"
          >
            <span class="truncate block">{{ s.title }}</span>
            <span class="text-[10px] text-white/30">{{ relativeTime(s.ts) }}</span>
          </button>
          <!-- Delete button -->
          <button
            class="p-1.5 mr-1 rounded-lg opacity-0 group-hover:opacity-100 text-white/30 hover:text-red-400 hover:bg-red-900/30 transition flex-shrink-0"
            title="Supprimer"
            @click.stop="deleteSession(s.id)"
          >
            <span class="material-symbols-outlined text-[15px]">delete</span>
          </button>
        </div>
      </SidebarSection>

      <SidebarSection v-if="archivedSessions.length" title="Archivé">
        <div
          v-for="s in archivedSessions"
          :key="s.id"
          class="flex items-center group rounded-lg hover:bg-white/10 transition"
        >
          <button
            class="flex-1 text-left px-3 py-2 text-sm text-white/40 truncate"
            @click="loadSession(s)"
          >
            {{ s.title }}
          </button>
          <button
            class="p-1.5 mr-1 rounded-lg opacity-0 group-hover:opacity-100 text-white/30 hover:text-red-400 hover:bg-red-900/30 transition flex-shrink-0"
            title="Supprimer"
            @click.stop="deleteSession(s.id)"
          >
            <span class="material-symbols-outlined text-[15px]">delete</span>
          </button>
        </div>
      </SidebarSection>
    </div>

    <div class="border-t border-white/10 px-4 py-3 flex-shrink-0">
      <p class="text-[10px] text-white/20 text-center">TechCorp AI · phi3-financial</p>
    </div>
  </aside>
</template>
