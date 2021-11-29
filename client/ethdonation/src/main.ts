import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import TopMenu from './components/TopMenu.vue';
import MessageInfo from './components/MessageInfo.vue';
import Expenses from './components/Expenses.vue';
import Donations from './components/Donations.vue';
import './css/style.css';

const app = createApp(App)
app.component('MessageInfo', MessageInfo)
app.component('TopMenu', TopMenu)
app.component('Expenses', Expenses)
app.component('Donations', Donations)
app.use(router)
app.mount('#app')
