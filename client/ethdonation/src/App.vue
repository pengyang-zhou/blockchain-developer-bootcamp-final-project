<template>
  <div id="app">
    <top-menu></top-menu>
    <div class="p-4">
      <router-view v-if="isRouterAlive"></router-view>
    </div>
  </div>
</template>

<script>
import {ref, nextTick, provide} from 'vue';

export default {
  name: 'App',
  setup() {
    const isRouterAlive = ref(true);
    const reload = () => {
      isRouterAlive.value = false;
      nextTick(() => {
        isRouterAlive.value = true;
      })
    };
    provide('reload', reload);
    return {
      isRouterAlive
    };
  },
}
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
}

#nav {
  padding: 30px;
}

#nav a {
  font-weight: bold;
  color: #2c3e50;
}

#nav a.router-link-exact-active {
  color: #42b983;
}
</style>
