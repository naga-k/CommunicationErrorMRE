// Log incoming messages
window.addEventListener('message', e => {
  try {
    // Ensure we're receiving from expected origin
    if (e.origin !== 'http://localhost:5000') {
      console.warn('Received message from unexpected origin:', e.origin);
      return;
    }

    if (typeof e.data !== 'string') {
      console.error('Expected string data but got:', typeof e.data);
      return;
    }

    const data = JSON.parse(e.data);
    // Log essential message info
    console.log('Received message:', {
      type: data.type,
      data: data.data
    });

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
  console.log('Editor iframe loaded');
} catch (error) {
  console.error('Error sending ready message:', error);
}