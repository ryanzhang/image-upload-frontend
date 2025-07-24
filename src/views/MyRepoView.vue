<template>
  <div>
    <div class="greetings">
        <!-- <img alt="Vue logo" class="profile_icon" src="" width="60" height="60" /> -->
        <h1>My Image Repo</h1>
        <img :src="profileIcon" alt="Profile Icon" class="profile-icon" width="60" height="60" />
    </div>
    <!-- Label list -->
    <div class="labels">
      <button @click="filterByLabel('All')">All</button>
      <button v-for="(label, index) in uniqueLabels" :key="index" @click="filterByLabel(label)">
        {{ label }}
      </button>
    </div>

    <!-- Image Table -->
    <table>
      <tbody>
        <tr v-for="(row, rowIndex) in filteredImageRows" :key="rowIndex">
          <td v-for="(image, colIndex) in row" :key="colIndex">
            <img :src="image.thumbUrl" :alt="image.name" @error="handleImageError($event, image.name)" @click="openFullImage(image.url, image.name)"/>
            <span v-if="image.showName">{{ image.name }}</span>
          </td>
        </tr>
      </tbody>
    </table>
    <!-- Full-Size Image Modal -->
    <div v-if="fullImageUrl" class="image-modal" @click="closeFullImage">
      <img :src="fullImageUrl" alt="Full Image" />
      <p class="image-name">{{ imageName }}</p>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'

//Ref for profile icon
const profileIcon = ref(null)

// Ref for the image rows
const imageRows = ref([])

// Ref for the selected label
const selectedLabel = ref('All')

// Ref for the full-size image URL
const fullImageUrl = ref(null)

const imageName = ref(null)


// Function to fetch images from the API
const fetchImages = async () => {
try {
    const apiUrl = window.env.VITE_ALBUM_API_URL || import.meta.env.VITE_ALBUM_API_URL;
    const apiUserKey = window.env.VITE_API_USER_KEY || import.meta.env.VITE_API_USER_KEY;
    //This should be get from login session, but leave it now
    //userId is the uique user input id, userObjectId is the system generated objectId
    const userId = window.env.VITE_USER_ID || import.meta.env.VITE_USER_ID;
    let userObjectId;
    try{
      console.log(apiUrl + '/users/search/' + userId + '?user_key=' + apiUserKey)
      const userResponse = await fetch(apiUrl + '/users/search/' + userId + '?user_key=' + apiUserKey)
      if (!userResponse.ok){
        throw new Error(`HTTP error! Status: ${userResponse.status} - ${userResponse.statusText}`);
      }
      let userData;
      userData = await userResponse.json();
      userObjectId =  userData.id;
      profileIcon.value = userData.profile.icon;
    } catch (jsonError){
      throw new Error('Failed to fetch User Profile: ' + jsonError.message);
 
    }

    console.log(apiUrl + '/images/' + userObjectId + '?user_key=' + apiUserKey)
    const response = await fetch(apiUrl + '/images/' + userObjectId + '?user_key=' + apiUserKey);

    // Check if the response is OK (status code 200-299)
    if (!response.ok) {
      throw new Error(`HTTP error! Status: ${response.status} - ${response.statusText}`);
    }

    let data;
    try {
      // Attempt to parse the JSON data
      data = await response.json();
    } catch (jsonError) {
      throw new Error('Failed to parse JSON: ' + jsonError.message);
    }

    console.log('Fetched image data:', data);

    // Assuming the data includes a "labels" field and "thumbUrl"
    const images = data.map(image => ({
      name: image.fileKey,
      url: image.url, // Use thumbUrl if available
      thumbUrl: image.thumbUrl,
      labels: image.labels || [], // Handle case where labels might not be present
      showName: false // Flag to control if name should be shown in case of error
    }));
    // const allLabels = new Set()
    // data.forEach(image => {
    //   image.labels.forEach(label => allLabels.add(label))
    // })

    // uniqueLabels.value = Array.from(allLabels)

    // Create rows of 5 images each
    imageRows.value = []; // Ensure imageRows is reset before pushing new rows
    for (let i = 0; i < images.length; i += 5) {
      imageRows.value.push(images.slice(i, i + 5));
    }

  } catch (error) {
    console.error('Error fetching images:', error.message);
  }
}


// Function to handle image loading error
const handleImageError = (event, imageName) => {
  // Hide the broken image and display the image name
  event.target.style.display = 'none' // Hide the broken image
  const image = imageRows.value.flat().find(img => img.name === imageName)
  if (image) {
    image.showName = true // Show the name as fallback
  }
}
// Function to filter images based on selected label
const filterByLabel = (label) => {
  selectedLabel.value = label
}

// Computed property to get all unique labels
const uniqueLabels = computed(() => {
  const allLabels = imageRows.value.flat().reduce((acc, image) => {
    return acc.concat(image.labels)
  }, [])
  return [...new Set(allLabels)]
})

// Computed property to get the filtered image rows based on the selected label
const filteredImageRows = computed(() => {
  if (selectedLabel.value === 'All') {
    console.log(imageRows.value)
    return imageRows.value
  } else {
    const filteredImages = imageRows.value.flat().filter(image => image.labels.includes(selectedLabel.value))
    const rows = []
    for (let i = 0; i < filteredImages.length; i += 5) {
      rows.push(filteredImages.slice(i, i + 5))
    }
    return rows
  }
})
// Function to open the full-size image in a modal
const openFullImage = (url, name) => {
  fullImageUrl.value = url
  imageName.value=name
}

// Function to close the full-size image modal
const closeFullImage = () => {
  fullImageUrl.value = null
}

// Call fetchImages when the component is mounted
onMounted(() => {
  fetchImages()
})
</script>

<style scoped>
.greetings {
  display: flex;
  justify-content: space-between; /* Distribute space between items */
  align-items: center; /* Align items vertically */
}
.profile-icon {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  margin-right: 10px;
}

table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 20px;
}

td {
  padding: 10px;
  text-align: center;
}

img {
  max-width: 100px; /* Adjust as necessary */
  max-height: 100px; /* Adjust as necessary */
}

span {
  font-size: 12px; /* Style for fallback text */
  color: #555;
}
/* Styles for label buttons */
.labels {
  margin-bottom: 20px;
}

.labels button {
  margin-right: 10px;
  padding: 1px 10px;
  border: none;
  background-color: #139b25;
  color: white;
  cursor: pointer;
}

.labels button:hover {
  background-color: #0056b3;
}


/* Modal styles for full-size image */
.image-modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.8);
  display: flex;
  justify-content: center;
  align-items: center;
  cursor: pointer;
}

.image-modal img {
  max-width: 90%;
  max-height: 90%;
}

.image-name {
  position: absolute;
  bottom: 10px;  /* Adjust the value as needed */
  width: 100%;
  text-align: center;
  color: white;
  font-size: 16px;  /* Adjust the size as needed */
}
</style>
