# Screenshots

Reference screenshots for the PRS static-design capstone — the page images shown in the
[PRS requirements](../prs-requirements.md) and used for peer review. Click a filename to
open the image.

## Pages

| Page | Route | Screenshot |
|---|---|---|
| Sign In | `/signin` | [signin.png](signin.png) |
| Requests List | `/requests` | [requests.png](requests.png) |
| Request Create | `/requests/create` | [requests-create.png](requests-create.png) |
| Request Edit | `/requests/edit/:id` | [requests-edit.png](requests-edit.png) |
| Request Detail | `/requests/detail/:id` | [requests-detail.png](requests-detail.png) |
| Line Item Create | `/requests/detail/:id/requestline/create` | [requests-detail-requestline-create.png](requests-detail-requestline-create.png) |
| Line Item Edit | `/requests/detail/:id/requestline/edit/:lineId` | [requests-detail-requestline-edit.png](requests-detail-requestline-edit.png) |
| Products List | `/products` | [products.png](products.png) |
| Product Create | `/products/create` | [products-create.png](products-create.png) |
| Product Edit | `/products/edit/:id` | [products-edit.png](products-edit.png) |
| Vendors List | `/vendors` | [vendors.png](vendors.png) |
| Vendor Create | `/vendors/create` | [vendors-create.png](vendors-create.png) |
| Vendor Edit | `/vendors/edit/:id` | [vendors-edit.png](vendors-edit.png) |
| Users List | `/users` | [users.png](users.png) |
| User Create | `/users/create` | [users-create.png](users-create.png) |
| User Edit | `/users/edit/:id` | [users-edit.png](users-edit.png) |

## Validation error states (empty submit)

The Lesson 6 form-validation error state for each create form and the Reject modal —
submit the empty form and compare the red fields and their messages. (Edit forms are
pre-filled and valid, so they have no error-state screenshot.)

| Page / Form | Screenshot |
|---|---|
| Sign In | [signin-invalid.png](signin-invalid.png) |
| User Create | [users-create-invalid.png](users-create-invalid.png) |
| Vendor Create | [vendors-create-invalid.png](vendors-create-invalid.png) |
| Product Create | [products-create-invalid.png](products-create-invalid.png) |
| Request Create | [requests-create-invalid.png](requests-create-invalid.png) |
| Line Item Create | [requests-detail-requestline-create-invalid.png](requests-detail-requestline-create-invalid.png) |
| Request Detail — Reject modal | [requests-detail-rejectModal-invalid.png](requests-detail-rejectModal-invalid.png) |

## Schema

| Diagram | Screenshot |
|---|---|
| Database diagram | [db-diagram.png](db-diagram.png) |
