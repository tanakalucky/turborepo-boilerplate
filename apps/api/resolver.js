// request mapping template
export function request(ctx) {
  return {
    version: '2017-02-28',
    operation: 'Invoke',
    payload: {
      field: ctx.arguments.field,
    },
  };
}

// response mapping template
export function response(ctx) {
  return ctx.result;
}
