export async function validate(schema, data) {
    try {
        await schema.validateAsync(data);

        return [];
    } catch (error) {
        return [{ field: error.details[0].path[0], message: error.details[0].message }] ;
    }
}