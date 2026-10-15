const {
  add,
  subtract,
  multiply,
  divide,
  modulo,
} = require("../src/calculator");
describe("calculator", () => {
  test("adds two numbers", () => {
    expect(add(2, 3)).toBe(6);
  });
  test("subtracts two numbers", () => {
    expect(subtract(5, 3)).toBe(2);
  });
  test("multiplies two numbers", () => {
    expect(multiply(4, 3)).toBe(12);
  });
  test("divides two numbers", () => {
    expect(divide(10, 2)).toBe(5);
  });
  test("throws when dividing by zero", () => {
    expect(() => divide(1, 0)).toThrow("Cannot divide by zero");
  });
  test("returns the remainder of a division", () => {
    expect(modulo(10, 3)).toBe(1);
  });
  test("modulo throws when dividing by zero", () => {
    expect(() => modulo(1, 0)).toThrow("Cannot divide by zero");
  });
});
