import { createRouter, createWebHistory } from 'vue-router'
import UploadView from '../views/UploadView.vue'
import MyProfileView from '../views/MyProfileView.vue'


const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: UploadView
    },
    {
      path: '/profile',
      name: 'profile',
      component: MyProfileView,
      props: true // This allows the route parameter to be passed as a prop to CatalogView
    },
    {
      path: '/repo',
      name: 'about',
      // route level code-splitting
      // this generates a separate chunk (About.[hash].js) for this route
      // which is lazy-loaded when the route is visited.
      component: () => import('../views/MyRepoView.vue')
    }
  ]
})

export default router
