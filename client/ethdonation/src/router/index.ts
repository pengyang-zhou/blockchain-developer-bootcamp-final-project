import { createRouter, createWebHistory, RouteRecordRaw } from 'vue-router'
import Projects from '../views/Projects.vue';
import NewProject from '../views/NewProject.vue';
import Project from '../views/Project.vue';
import NewExpense from '../views/NewExpense.vue';
import ErrorPage from '../views/ErrorPage.vue';

const routes: Array<RouteRecordRaw> = [
  {
    path: '/projects',
    alias: '/',
    name: 'Projects',
    component: Projects
  },
  // {
  //   path: '/projects?mine=true',
  //   name: 'MyProjects',
  //   component: Projects
  // },
  {
    path: '/new',
    name: 'NewProject',
    component: NewProject
  },
  {
    path: '/project/:id',
    name: 'Project',
    component: Project
  },
  {
    path: '/project/:id/new',
    name: 'NewExpense',
    component: NewExpense
  },
  {
    path: '/error',
    name: 'Error',
    component: ErrorPage
  }
]

const router = createRouter({
  history: createWebHistory(process.env.BASE_URL),
  routes
})

export default router
