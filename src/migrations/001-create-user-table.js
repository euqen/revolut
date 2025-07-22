import { DataTypes } from 'sequelize';

    export function up({context}) {

      return context.createTable('Users', {
        id: {
          type: DataTypes.INTEGER,
          autoIncrement: true,
          primaryKey: true,
        },
        username: {
          type: DataTypes.STRING,
          allowNull: false,
          unique: true,
        },
        dateOfBirth: {
          type: DataTypes.STRING,
          allowNull: false,
        },
      }, {
        timestamps: false,
      });
    }

    export function down({context}) {
      return context.dropTable('Users');
    }