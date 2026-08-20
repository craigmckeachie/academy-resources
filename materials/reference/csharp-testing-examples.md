# Unit Testing and Mocking in C# — Example Code

A small worked example to clone and read: a C# class library with a test project,
showing **xUnit** and **Moq**. Optional — nothing in any capstone depends on it. It's
here as the C# counterpart to the Vitest testing in **React Lessons 17–20**.

Repository: <https://github.com/craigmckeachie/csharp-testing>

```bash
git clone https://github.com/craigmckeachie/csharp-testing.git
```

## What it is

**Storefront** is a fictional online store with exactly one job — place an order.
`OrderFulfillmentService.PlaceOrder` checks stock, charges the customer, reserves the
stock, works out a shipping date, and emails a confirmation.

That short list is the whole point: placing an order depends on four things a test
cannot use for real.

| Collaborator | Why a test can't use the real one |
|---|---|
| `IPaymentGateway` | Moves real money — and won't decline or time out on request |
| `IEmailSender` | A side effect a test must not actually perform |
| `IInventoryService` | Stock levels would otherwise need a seeded database |
| `IClock` | `DateTime.Now` makes a date test pass today and fail on Friday |

A `Mock<T>` stands in for each one.

## Two branches

| Branch | What's in it |
|---|---|
| `main` | The class library and its tests. No API and no database — `dotnet test` runs on a clean clone. |
| `layered` | The same library and the same tests, plus a Web API and an Entity Framework implementation, so you can see where a tested service sits in a real app. |

`git diff main..layered` shows exactly what the layers add — and shows that the service
and its tests are untouched by them.

## What to read first

1. **`Storefront/Utilities/ShippingCalendar.cs`** and its tests — pure logic, nothing to
   fake, no mocks at all.
2. **`Storefront/Services/OrderFulfillmentService.cs`** — the same app's orchestration.
   Knowing which of these two you're looking at is the skill.
3. **`Storefront.Tests/OrderFulfillmentServiceTests.cs`**, starting with
   `PlaceOrder_WhenStockIsInsufficient_DoesNotChargeTheCustomer`. You cannot ask a real
   payment processor to prove it did *not* take someone's money — `Times.Never` is how
   you assert that something did not happen.
4. On the `layered` branch, **`Storefront.Api/Program.cs`** beside that same test file.
   Both answer the question *what satisfies these four interfaces?* — and they answer it
   differently, without the service knowing either answer.

## Coming from Vitest

| Vitest (React Lessons 17–20) | xUnit / Moq |
|---|---|
| `describe` / `it` | test class / `[Fact]` |
| `expect(x).toBe(y)` | `Assert.Equal(y, x)` |
| `it.each` | `[Theory]` + `[InlineData]` |
| `vi.fn()` / `vi.spyOn` | `Mock<T>` / `Verify` |
| MSW intercepting the network | `Mock<IPaymentGateway>` replacing the collaborator |

The repository's README covers the rest, including an exercise that makes one test fail
on purpose — because a test you've never seen go red hasn't been verified.
