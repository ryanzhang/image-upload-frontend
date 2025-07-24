<template>
  <div class="profile-view">
    <h1>My Profile</h1>
    
    <div class="profile-info">
      <div class="profile-field">
        <label for="firstname">First Name:</label>
        <input 
          type="text" 
          id="firstname" 
          v-model="profile.firstname" 
        />
      </div>

      <div class="profile-field">
        <label for="lastname">Last Name:</label>
        <input 
          type="text" 
          id="lastname" 
          v-model="profile.lastname" 
        />
      </div>

      <div class="profile-field">
        <label for="email">Email:</label>
        <input 
          type="text" 
          id="email" 
          v-model="profile.email" 
          disabled 
          class="disabled-field"
        />
      </div>

      <div class="profile-field">
        <label for="userid">User ID:</label>
        <input 
          type="text" 
          id="userid" 
          v-model="profile.userid" 
          disabled 
          class="disabled-field"
        />
      </div>

      <div class="profile-field">
        <label for="password">Password:</label>
        <input 
          type="password" 
          id="password" 
          v-model="profile.password" 
        />
      </div>

      <div class="profile-field">
        <label for="icon">Profile Icon:</label>
        <div class="icon-container">
          <div class="icon-container-inner">
            <img :src="profile.profile.icon" alt="Profile Icon" class="profile-icon" @click="toggleIconInput"/>
            <!-- <button @click="toggleIconInput">Update</button> -->
            <a href="javascript:void(0)" @click="toggleIconInput">Change</a>
          </div>
          <input 
            v-if="showIconInput"
            type="text" 
            id="icon" 
            v-model="iconUrl" 
            placeholder="Enter icon URL"
            class="icon-input"
          />
        </div>
      </div>

      <div class="profile-field">
        <label for="bio">Bio:</label>
        <input 
          type="text" 
          id="bio" 
          v-model="profile.profile.bio" 
        />
      </div>

      <div class="profile-field">
        <label for="language">Language:</label>
        <select v-model="profile.settings.language">
          <option value="en">English</option>
          <option value="es">Spanish</option>
          <option value="cn">中文</option>
          <!-- Add more languages as needed -->
        </select>
      </div>

      <div class="profile-field">
        <label for="privacy">Privacy:</label>
        <input 
          type="checkbox" 
          id="privacy" 
          v-model="profile.settings.privacy" 
        />
      </div>

      <button @click="saveProfile">Save Changes</button>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
import { ref } from 'vue'
export default {
  data() {
    return {
      profile: {
        id: '',
        userid: '',
        firstname: '',
        lastname: '',
        email: '',
        password: '',
        profile: {
          icon: '',
          bio: ''
        },
        folder: '',
        settings: {
          language: 'en',
          privacy: false
        },
      },
      iconUrl: '',
      showIconInput: false
    };
  },
  mounted() {
    this.fetchProfile();
  },
  methods: {
    async fetchProfile() {
      const apiUrl = window.env.VITE_ALBUM_API_URL || import.meta.env.VITE_ALBUM_API_URL;
      const apiUserKey = window.env.VITE_API_USER_KEY || import.meta.env.VITE_API_USER_KEY;
      const userId = window.env.VITE_USER_ID || import.meta.env.VITE_USER_ID;
      const response = await fetch(apiUrl + '/users/search/' + userId + '?user_key=' + apiUserKey);
      const data = await response.json();
      this.profile = data;
      this.iconUrl = data.profile.icon; // Initialize iconUrl with current icon URL
      this.profile.id = data.id
    },
    async saveProfile() {
      // Prepare the profile data to send to the server
      const updatedProfile = {
        ...this.profile,
        profile: {
          ...this.profile.profile,
          icon: this.iconUrl // Update icon URL from input
        }
      };

      let updateStatus = ref('');
      try {
          const apiUrl = window.env.VITE_ALBUM_API_URL || import.meta.env.VITE_ALBUM_API_URL;
          const apiUserKey = window.env.VITE_API_USER_KEY || import.meta.env.VITE_API_USER_KEY;
          const response = await axios.put(apiUrl + '/users/' + this.profile.id, {
          ...updatedProfile,
          params: {
              user_key: apiUserKey
          }
          });

          updateStatus.value = `${response.data}`;
          console.log('Update response:', response);  // Log full response for debugging


      } catch (error) {
          // Detailed error handling
          if (error.response) {
          // Server-side error
          console.error('Server responded with error:', error.response);
          updateStatus.value = `Server Error: ${error.response.status} - ${error.response.data.message || error.response.data}`;
          } else if (error.request) {
          // No response received from the server
          console.error('No response received:', error.request);
          updateStatus.value = 'Error: No response from the server. Please check your network or try again later.';
          } else {
          // Other errors (e.g., request setup issues)
          console.error('Error setting up request:', error.message);
          updateStatus.value = `Error: ${error.message}`;
          }
      } finally {
          // Reset loading state after completion
      }      

      // Send the updated profile data to the server
      // Implement the API call here to save the updated profile
      console.log('Saving profile:', updatedProfile);
    },
    toggleIconInput() {
      this.showIconInput = !this.showIconInput;
    }
  }
  
};
</script>

<style scoped>
.profile-info {
  display: flex;
  flex-direction: column;
  margin-top: 20px;
}

.profile-field {
  margin-bottom: 15px;
}

.profile-field label {
  font-weight: bold;
}

input[type="text"],
input[type="password"],
select {
  width: 100%;
  padding: 8px;
  margin-top: 5px;
  border: 1px solid #ccc;
  border-radius: 4px;
}

.disabled-field {
  background-color: #f0f0f0;
  color: #666;
  cursor: not-allowed;
}

.icon-container {
  display: flex;
  align-items: left;
}
.icon-container-inner {
  display: flex;
  align-items: center;
  flex-direction: column; /* Arrange elements vertically */

}

.profile-icon {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  margin-right: 10px;
  cursor: pointer; /* Makes it clear the image is clickable */
  margin-bottom: 5px; /* Adjust the spacing as needed */
}
a {
  color: #0056b3; /* Link color */
  cursor: pointer;
  text-decoration: underline;
}
.icon-input {
  height: auto; /* Set to auto to avoid excessive height */
  align-self: center; /* Align input to the center */
}
button {
  margin-top: 20px;
  padding: 10px;
  border: none;
  background-color: #139b25;
  color: white;
  cursor: pointer;
  border-radius: 4px;
}

button:hover {
  background-color: #0056b3;
}
</style>
