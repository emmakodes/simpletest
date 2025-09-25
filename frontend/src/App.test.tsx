import { render } from "@testing-library/react"
import { describe, it, expect } from "vitest"
import App from "./App"

describe("App", () => {
  it("renders title", () => {
    const { getByText } = render(<App />)
    expect(getByText("Todo")).toBeTruthy()
  })
})


