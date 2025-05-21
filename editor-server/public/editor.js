// Log incoming messages
window.addEventListener('message', e => {
  try {
    // Ensure we're receiving from expected origin
    if (e.origin !== 'http://localhost:5000') {
      console.warn('Received message from unexpected origin:', e.origin);
      return;
    }

    // Parse incoming data if it's a string
    const data = typeof e.data === 'string' ? JSON.parse(e.data) : e.data;
    console.log('Editor received:', data);

  } catch (error) {
    console.error('Error processing message:', error);
  }
});

// Notify parent when loaded
try {
  const message = { 
    type: 'iframeLoaded',
    timestamp: Date.now()
  };
  parent.postMessage(JSON.stringify(message), 'http://localhost:5000');
  console.log('Editor iframe loaded, sent ready message');
} catch (error) {
  console.error('Error sending ready message:', error);
}