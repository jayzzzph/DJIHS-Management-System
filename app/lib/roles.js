// Dashboard home for each user role. Roles are compared case-insensitively.
const ROLE_HOME = {
  "registrar": "/dashboard",
  "key teacher": "/dashboard/kteacher",
  "subject teacher": "/dashboard/teacher",
};

export const normalizeRole = (role) => role?.trim().toLowerCase() || "";

export const getRoleHome = (role) => ROLE_HOME[normalizeRole(role)] || "/dashboard";
