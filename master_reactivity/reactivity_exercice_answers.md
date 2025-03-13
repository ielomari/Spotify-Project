---
title: "reactivity_exercice_answers"
---

## **1. Difference between `reactive()` and `eventReactive()`**

### **`reactive()`**
- `reactive()` creates a reactive expression that automatically updates whenever its dependencies change.
- It is used for computations that need to be recalculated whenever the input changes.

### **`eventReactive()`**
- `eventReactive()` is similar to `reactive()`, but it only updates when a specific event (e.g., button click) occurs.
- It is useful when you want to delay execution until the user triggers it.

**Example:**
- Use `reactive()` when filtering data based on a dropdown selection that should update instantly.
- Use `eventReactive()` when the user needs to click a button before filtering updates.

---

## **2. Difference between `observe()` and `observeEvent()`**

### **`observe()`**
- `observe()` runs code reactively whenever dependencies change but does not return a value.
- Used for side effects like logging, updating UI elements, or writing to a database.

### **`observeEvent()`**
- `observeEvent()` runs only when a specific event (e.g., button click) occurs.
- It prevents unnecessary execution when the event has not happened yet.

**Example:**
- Use `observe()` to log user input changes in the console.
- Use `observeEvent()` to execute a function only when a button is clicked.

---

## **3. Why is `reactiveValues()` necessary?**
- `reactiveValues()` creates a list of reactive variables that store persistent state across sessions.
- It is used when multiple variables need to be updated independently.

**Example:**
- Use `reactiveValues()` to track a user’s score in a game, which updates independently.

---

## **4. Error when using reactive content outside of a reactive context**
- If a reactive expression is accessed outside of `render*()` or `observe()` functions, an error occurs: **"Operation not allowed outside of reactive context"**.
- This happens because reactivity requires a **reactive environment** to track dependencies.

**Solution:**
- Ensure that reactive expressions are used inside `renderText()`, `renderTable()`, `observe()`, etc.

---

## **5. How Shiny updates outputs automatically**
- Shiny uses a dependency-tracking system where reactive expressions and observers monitor changes to inputs.
- When an input changes, all dependent reactive expressions and UI elements update automatically.
- This eliminates the need for manual updates, making apps dynamic and responsive.

**Example:**
- A `renderPlot()` function will automatically update whenever an input value changes.

---
