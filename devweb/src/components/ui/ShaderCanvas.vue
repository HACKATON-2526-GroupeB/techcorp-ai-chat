<template>
  <div class="absolute inset-0 overflow-hidden">
    <!-- Animated ambient blobs -->
    <div class="blob blob-1" />
    <div class="blob blob-2" />
    <div class="blob blob-3" />
  </div>
</template>

<style scoped>
.blob {
  position: absolute;
  border-radius: 50%;
  filter: blur(80px);
  opacity: 0.18;
  animation: drift 12s ease-in-out infinite alternate;
}
.blob-1 {
  width: 55vw; height: 55vw;
  background: radial-gradient(circle, #6366f1, transparent 70%);
  top: -20%; left: -10%;
  animation-duration: 14s;
}
.blob-2 {
  width: 40vw; height: 40vw;
  background: radial-gradient(circle, #8b5cf6, transparent 70%);
  bottom: -15%; right: -5%;
  animation-duration: 18s;
  animation-delay: -6s;
}
.blob-3 {
  width: 30vw; height: 30vw;
  background: radial-gradient(circle, #3b82f6, transparent 70%);
  top: 40%; left: 50%;
  animation-duration: 22s;
  animation-delay: -3s;
}
@keyframes drift {
  0%   { transform: translate(0, 0) scale(1); }
  33%  { transform: translate(4%, 6%) scale(1.08); }
  66%  { transform: translate(-3%, 3%) scale(0.95); }
  100% { transform: translate(5%, -4%) scale(1.05); }
}
</style>
