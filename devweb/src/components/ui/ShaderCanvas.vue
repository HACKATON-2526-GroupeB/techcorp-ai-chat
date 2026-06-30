<template>
  <canvas ref="canvas" class="absolute inset-0 w-full h-full opacity-20 pointer-events-none" />
</template>
<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
const canvas = ref(null)
let raf
onMounted(() => {
  const c = canvas.value
  if (!c) return
  const ctx = c.getContext('2d')
  let t = 0
  function draw() {
    c.width = c.offsetWidth; c.height = c.offsetHeight
    ctx.clearRect(0, 0, c.width, c.height)
    for (let i = 0; i < 3; i++) {
      const x = c.width * (0.3 + 0.4 * Math.sin(t * 0.3 + i * 2))
      const y = c.height * (0.3 + 0.4 * Math.cos(t * 0.2 + i * 1.5))
      const r = Math.min(c.width, c.height) * 0.4
      const g = ctx.createRadialGradient(x, y, 0, x, y, r)
      g.addColorStop(0, `hsla(${220 + i * 30},80%,60%,0.15)`)
      g.addColorStop(1, 'transparent')
      ctx.fillStyle = g
      ctx.fillRect(0, 0, c.width, c.height)
    }
    t += 0.01
    raf = requestAnimationFrame(draw)
  }
  draw()
})
onUnmounted(() => cancelAnimationFrame(raf))
</script>
