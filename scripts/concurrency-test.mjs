const baseURL =
  process.argv[2] ?? "http://127.0.0.1:8787";

// Use a new event on each test run.
const eventId = `race-${Date.now()}`;
const endpoint =
  `${baseURL}/api/events/${eventId}`;

const USERS = 20;

console.log("Event:", eventId);
console.log("Concurrent users:", USERS);

// Step 1: Read initial inventory.
const initialResponse = await fetch(endpoint);

if (!initialResponse.ok) {
  throw new Error(
    `Initial request failed: ${initialResponse.status}`
  );
}

const initial = await initialResponse.json();
console.log("Initial state:", initial);

// Step 2: Generate 20 simultaneous requests.
const tasks = Array.from(
  { length: USERS },
  (_, i) => {
    return fetch(`${endpoint}/reservations`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        userId: `user-${i + 1}`,
        requestId: `request-${i + 1}`
      })
    }).then(async response => ({
      httpStatus: response.status,
      ...(await response.json())
    }));
  }
);

// Step 3: Run all requests concurrently.
const results = await Promise.all(tasks);

// Step 4: Count results.
const successful = results.filter(
  result => result.ok === true
);

const failed = results.filter(
  result =>
    result.ok === false &&
    result.reason === "sold_out"
);

// Step 5: Read final inventory.
const finalResponse = await fetch(endpoint);

if (!finalResponse.ok) {
  throw new Error(
    `Final request failed: ${finalResponse.status}`
  );
}

const final = await finalResponse.json();

// Step 6: Verify consistency.
console.log("\nResults:");
console.log("Successful:", successful.length);
console.log("Sold out:", failed.length);
console.log("Final state:", final);

const consistent =
  successful.length === 5 &&
  failed.length === (USERS - 5) &&
  final.capacity === 5 &&
  final.remaining === 0 &&
  final.reserved === 5 &&
  final.capacity === final.remaining + final.reserved;

console.log(
  "\nConsistency check:",
  consistent ? "PASS" : "FAIL"
);

if (!consistent) {
  process.exitCode = 1;
}
