<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import Sidebar       from './components/layout/Sidebar.vue'
import TopBar        from './components/layout/TopBar.vue'
import InputArea     from './components/layout/InputArea.vue'
import ChatViewport  from './components/chat/ChatViewport.vue'
import SettingsPanel from './components/settings/SettingsPanel.vue'
import ShaderCanvas  from './components/ui/ShaderCanvas.vue'
import { useChat }   from './composables/useChat'
import { useModels } from './composables/useModels'

const { messages, loading, ollamaOnline, send, stop, clearChat, checkStatus } = useChat()
const { fetchModels } = useModels()
const showSettings = ref(false)
let interval

onMounted(async () => {
  await checkStatus()
  await fetchModels()
  interval = setInterval(async () => {
    await checkStatus()
    if (ollamaOnline.value) fetchModels()
  }, 30_000)
})
onUnmounted(() => clearInterval(interval))
</script>

<template>
  <div class="flex h-screen overflow-hidden" style="background:#09090B">
    <Sidebar @clear-chat="clearChat" @toggle-settings="showSettings = !showSettings" />

    <main class="ml-[280px] flex-1 flex flex-col relative overflow-hidden">
      <ShaderCanvas class="absolute inset-0 pointer-events-none z-0" />
      <div class="relative z-10 flex flex-col h-full">
        <TopBar :ollama-online="ollamaOnline" @toggle-settings="showSettings = !showSettings" />
        <ChatViewport :messages="messages" :loading="loading" @suggest="send" />
        <InputArea :loading="loading" @send="send" @stop="stop" />
      </div>
    </main>

    <SettingsPanel :show="showSettings" @close="showSettings = false" />
  </div>
</template>
