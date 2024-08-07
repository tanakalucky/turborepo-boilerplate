'use client';

import { ReactNode } from 'react';
import { cacheExchange, Client, fetchExchange, Provider } from 'urql';

export function GraphqlProvider({ url, apiKey, children }: { url: string; apiKey: string; children: ReactNode }) {
  const client = new Client({
    url,
    exchanges: [cacheExchange, fetchExchange],
    fetchOptions: () => {
      return {
        headers: { 'x-api-key': apiKey },
      };
    },
  });

  return <Provider value={client}>{children}</Provider>;
}
