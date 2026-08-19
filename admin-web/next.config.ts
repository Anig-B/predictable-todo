import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  turbopack: {
    // Restricts Turbopack scanning strictly to admin-web
    root: __dirname,
  },
  experimental: {
    // Speeds up compilation for icon libraries
    optimizePackageImports: ["lucide-react", "@radix-ui/react-icons"],
  },
  // Optional: Only used if running dev server with `--webpack`
  webpack: (config) => {
    config.watchOptions = {
      ...config.watchOptions,
      ignored: [
        "**/.git/**",
        "**/node_modules/**",
        "**/.next/**",
        "**/build/**",
        "**/.dart_tool/**",
      ],
    };
    return config;
  },
};

export default nextConfig;
