<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import Sidebar       from './components/layout/Sidebar.vue'
import TopBar        from './components/layout/TopBar.vue'
import InputArea     from './components/layout/InputArea.vue'
import ChatViewport  from './components/chat/ChatViewport.vue'
import SettingsPanel from './components/settings/SettingsPanel.vue'
import { useChat }   from './composables/useChat'
import { useModels } from './composables/useModels'

const { messages, loading, ollamaOnline, send, clearChat, checkStatus } = useChat()
const { fetchModels } = useModels()

const showSettings = ref(false)

let statusInterval

onMounted(async () => {
  await checkStatus()
  await fetchModels()
  statusInterval = setInterval(async () => {
    await checkStatus()
    // Re-fetch models si Ollama vient de revenir en ligne
    if (ollamaOnline.value) fetchModels()
  }, 30_000)
})

onUnmounted(() => clearInterval(statusInterval))
</script>

<template>
  <div class="flex h-screen overflow-hidden">
    <Sidebar @clear-chat="clearChat" @toggle-settings="showSettings = !showSettings" />

    <main class="ml-[280px] flex-1 flex flex-col ambient-bg relative overflow-hidden">
      <TopBar
        :ollama-online="ollamaOnline"
        @toggle-settings="showSettings = !showSettings"
      />

      <ChatViewport :messages="messages" :loading="loading" />

      <InputArea :loading="loading" @send="send" />
    </main>

    <SettingsPanel :show="showSettings" @close="showSettings = false" />
  </div>
</template>
