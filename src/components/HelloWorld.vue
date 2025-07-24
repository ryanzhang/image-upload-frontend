<script setup>
defineProps({
  msg: {
    type: String,
    required: true
  }
})
</script>

<template>
  <div class="greetings">
    <img alt="Vue logo" class="logo" src="@/assets/logo.svg" width="60" height="60" />
   <div class="title-container">
      <h1 class="green">{{ msg }}</h1>
      <h3>A demo to OpenShift Serverless</h3>
    </div>
  </div>
</template>

<style scoped>
h1 {
  font-weight: 500;
  font-size: 2.2rem;
  position: relative;
  top: -10px;
}

h3 {
  font-size: 1.2rem;
}

.greetings {
  display: flex;
  align-items: center; /* Align items vertically */
}

.logo {
  margin-right: 10px; /* Space between the logo and title */
}

.title-container {
  display: flex;
  flex-direction: column; /* Stack title and subtitle vertically */
  margin-left: 10px; /* Space between logo and title */
}

.greetings h1,
.greetings h3 {
  text-align: center;
}

@media (min-width: 1024px) {
  .greetings h1,
  .greetings h3 {
    text-align: left;
  }
}
</style>
