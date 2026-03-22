package model;

public class UserWarehouse extends BaseModel {

    private int userWarehouseId;
    private int userId;
    private int warehouseId;

    public UserWarehouse() {
    }

    public int getUserWarehouseId() {
        return userWarehouseId;
    }

    public void setUserWarehouseId(int userWarehouseId) {
        this.userWarehouseId = userWarehouseId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getWarehouseId() {
        return warehouseId;
    }

    public void setWarehouseId(int warehouseId) {
        this.warehouseId = warehouseId;
    }
}
