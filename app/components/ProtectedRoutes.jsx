"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { getSessionUser } from "@/app/lib/data";
import { getRoleHome, normalizeRole } from "@/app/lib/roles";

export default function RoleGuard({ children, allowedRole }) {
  const [authorized, setAuthorized] = useState(false);
  const router = useRouter();

  useEffect(() => {
    const checkAccess = async () => {
      const user = await getSessionUser();

      // 1. Check if user exists
      if (!user) {
        router.replace("/login");
        return;
      }

      // 2. Check if role matches (case-insensitive)
      if (normalizeRole(user.role) !== normalizeRole(allowedRole)) {
        // Send them to their actual assigned dashboard
        router.replace(getRoleHome(user.role));
        return;
      }

      setAuthorized(true);
    };

    checkAccess();
  }, [allowedRole, router]);

  if (!authorized) return <div style={{ padding: "2rem" }}>Verifying permissions...</div>;

  return <>{children}</>;
}