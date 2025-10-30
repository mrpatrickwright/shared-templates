<template>
  <div class="base-select">
    <label v-if="title" :for="selectId" class="select-label">
      {{ title }}
    </label>
    <select
      :id="selectId"
      v-model="selectValue"
      :disabled="disabled"
      :class="selectClasses"
      @change="$emit('change', $event)"
    >
      <option value="" disabled>
        {{ placeholder || "Select an option..." }}
      </option>
      <option
        v-for="option in options"
        :key="option[selectKey]"
        :value="option[selectKey]"
      >
        {{ option[selectDisplayValue] }}
      </option>
    </select>
    <div v-if="error" class="error-message">
      {{ error }}
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, ref } from "vue";

const props = defineProps({
  modelValue: {
    type: [String, Number],
    default: "",
  },
  title: {
    type: String,
    default: "",
  },
  options: {
    type: Array,
    default: () => [],
  },
  selectKey: {
    type: String,
    default: "id",
  },
  selectDisplayValue: {
    type: String,
    default: "name",
  },
  placeholder: {
    type: String,
    default: "",
  },
  disabled: {
    type: Boolean,
    default: false,
  },
  error: {
    type: String,
    default: "",
  },
});

const emit = defineEmits(["update:modelValue", "change"]);

const selectId = ref(`select-${Math.random().toString(36).substr(2, 9)}`);

const selectValue = computed({
  get: () => props.modelValue,
  set: (value) => emit("update:modelValue", value),
});

const selectClasses = computed(() => [
  "form-select",
  {
    "select-error": props.error,
    "select-disabled": props.disabled,
  },
]);
</script>

<style scoped>
.base-select {
  margin-bottom: 1rem;
}

.select-label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 500;
  color: #374151;
}

.form-select {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #d1d5db;
  border-radius: 0.375rem;
  font-size: 0.875rem;
  color: #374151;
  background-color: white;

  background-position: right 0.5rem center;
  background-repeat: no-repeat;
  background-size: 1.5em 1.5em;
  padding-right: 2.5rem;
  transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;
  cursor: pointer;
}

.form-select:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.select-error {
  border-color: #ef4444;
}

.select-error:focus {
  border-color: #ef4444;
  box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.1);
}

.select-disabled {
  background-color: #f9fafb;
  cursor: not-allowed;
}

.error-message {
  margin-top: 0.25rem;
  font-size: 0.75rem;
  color: #ef4444;
}
</style>
