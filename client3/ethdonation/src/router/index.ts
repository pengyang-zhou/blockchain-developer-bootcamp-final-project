import { createRouter, createWebHashHistory, RouteRecordRaw } from 'vue-router'
import Projects from '../views/Projects.vue';
import MyProjects from '../views/MyProjects.vue';
import NewProject from '../views/NewProject.vue';
import Project from '../views/Project.vue';

const routes: Array<RouteRecordRaw> = [
  {
    path: '/',
    name: 'Projects',
    component: Projects
  },
  {
    path: '/my',
    name: 'MyProjects',
    component: MyProjects
  },
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
    path: '/about',
    name: 'About',
    // route level code-splitting
    // this generates a separate chunk (about.[hash].js) for this route
    // which is lazy-loaded when the route is visited.
    component: () => import(/* webpackChunkName: "about" */ '../views/About.vue')
  }
]

const router = createRouter({
  history: createWebHashHistory(),
  routes
})

export default router
