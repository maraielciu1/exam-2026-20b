# Exam Requirement: Calorie Management App
A group of users is managing their daily calorie budget using a mobile application. Each user can track and analyze their calorie intake and burn.

On the server side, at least the following details are maintained:
- `id`: The unique identifier for the log entry. Integer value greater than zero.
- `date`: The date when the activity occurred. A string in the format "YYYY-MM-DD".
- `amount`: The amount of calories (burned or consumed). A decimal value.
- `type`: The type of log (e.g., intake or burn). A string of characters.
- `category`: The category of the activity (e.g., lunch, running, snack). A string of characters.
- `description`: A description of the transaction. A string of characters.

The application should provide at least the following features:

## Main Section (Separate Screen/Activity)
> **Note:** Each feature in this section should be implemented in a separate screen unless otherwise specified.

- A. **(1p) View the list of logs**: Using the `GET /logs` call, users can retrieve all their calorie logs. If offline, the app will display an offline message and provide a retry option. Once retrieved, the data should be available on the device, regardless of whether online or offline.
- B. **(2p) View Log Details**: By selecting a log from the list, the user can view its details. The `GET /log/:id` call will retrieve specific log details. Once retrieved, the data should be available on the device, regardless of whether online or offline.
- C. **(1p) Add a new log**: Users can create a new log using the `POST /log` call by specifying all details. This feature is available online only.
- D. **(1p) Delete a log**: Users can delete a log using the `DELETE /log/:id` call by selecting it from the list. This feature is available online only.

## Reports Section (Separate Screen/Activity)

**(1p) Monthly Calorie Analysis**: Using the `GET /allLogs` call, the app will retrieve all logs and compute the list of monthly totals, displayed in descending order.

## Insights Section (Separate Screen/Activity)

**(1p) Top Categories**: View the top 3 activities/meals by calories. Using the same `GET /allLogs` call, the app will compute and display the top 3 categories and their total amounts in descending order.

## Additional Features
- **(1p) WebSocket Notifications**: When a new log is added, the server will use a WebSocket channel to send the log details to all connected clients. The app will display the received data in human-readable form (e.g., as a toast, snackbar, or dialog).
- **(0.5p) Progress Indicator**: A progress indicator will be displayed during server operations.
- **(0.5p) Error Handling & Logging**: Any server interaction errors will be displayed using a toast or snackbar, and all interactions (server or DB) will log a message.

## Server Info
- Location: `./server`
- Install: `npm install`
- Run: `npm start`
- Port: 2621
