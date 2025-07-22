import Joi from "joi";
import { validate } from "../../utils/validate.js";

export async function validateUpsertUsername(req, res, next) {
    const params = req.params;
    const body = req.body;

    const paramsSchema = Joi.object({
        username: Joi
            .string()
            .pattern(/^[a-zA-Z]+$/)
            .required(),
    });

    const bodySchema = Joi.object({
        dateOfBirth: Joi
            .string()
            .pattern(/^\d{4}-\d{2}-\d{2}$/)
            .required(),
    });

    const errors = [
        ...(await validate(paramsSchema, params)), 
        ...(await validate(bodySchema, body))
    ];

    if (errors.length > 0) {
        return res.status(400).json({ errors });
    }

    const dateOfBirth = new Date(body.dateOfBirth);

    if (dateOfBirth.toString() === "Invalid Date") {
        return res.status(400).json({ 
            errors: [{ field: "body.dateOfBirth", message: "Date of birth is not a valid date" }] 
        });
    }

    const today = new Date();

    if (dateOfBirth > today) {
        return res.status(400).json({ 
            errors: [{ field: "body.dateOfBirth", message: "Date of birth cannot be in the future" }] 
        });
    }

    next();
}