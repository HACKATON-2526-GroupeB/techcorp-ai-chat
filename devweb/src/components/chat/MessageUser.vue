<script setup>
defineProps({ message: Object })
function fmt(ts) {
  return new Date(ts).toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })
}
</script>
<template>
  <div class="flex justify-end mb-5 px-4">
    <div class="max-w-[70%]">
      <div class="bg-indigo-600/25 border border-indigo-500/20 rounded-2xl rounded-tr-sm px-4 py-3 text-sm text-white whitespace-pre-wrap">
        {{ message.content }}
      </div>
      <p class="text-[10px] text-white/20 mt-1 text-right pr-1">{{ fmt(message.ts) }}</p>
    </div>
  </div>
</template>
