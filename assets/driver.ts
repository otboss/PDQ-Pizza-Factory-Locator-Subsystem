/** A JavaScript driver for the Pizza Factory Locator Subsytem*/
export abstract class PizzaFactoryLocator {
    /** Sets the configuration */
    public setConfig(
        mongo_address: string,
        mongo_username: string,
        mongo_password: string,
        mongo_port: number,
        orders_collection: string,
        latitude_field: string,
        longitude_field: string,
    ) {

    }

    /**  */
    public getNewFactoryLocation() {

    }
}