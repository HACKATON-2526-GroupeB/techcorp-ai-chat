<script setup>
defineProps({ message: Object })
function fmt(ts) {
  return new Date(ts).toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })
}
</script>
<template>
  <div class="flex justify-end mb-4 px-4">
    <div class="max-w-[70%]">
      <p class="text-[10px] text-white/30 text-right mb-1 uppercase tracking-widest">{{ fmt(message.ts) }}</p>
      <div class="bg-white/10 rounded-2xl rounded-tr-sm px-4 py-3 text-sm text-white whitespace-pre-wrap">{{ message.content }}</div>
    </div>
  </div>
</template>
